import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/current_time.dart';
import '../../application/providers.dart';
import '../../core/dictation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/quick_capture_parser.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/localized_dates.dart';
import '../settings/settings_controller.dart';

/// Returns the last saved Item, including when continued capture is dismissed.
Future<Item?> showCaptureSheet(
  BuildContext context, {
  String? initialText,
}) async {
  Item? lastCaptured;
  final result = await showModalBottomSheet<Item>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    // Drag dismissal bypasses PopScope, so use Cancel/back/barrier dismissal
    // and keep a pending save on screen until its result is known.
    enableDrag: false,
    showDragHandle: false,
    builder: (_) => CaptureSheet(
      initialText: initialText,
      onCaptured: (item) => lastCaptured = item,
    ),
  );
  return result ?? lastCaptured;
}

/// Appends a dictation [transcript] to the [prefix] typed before dictation
/// started, adding a space unless the prefix is empty or already ends in
/// whitespace.
@visibleForTesting
String appendDictation(String prefix, String transcript) {
  if (prefix.isEmpty || RegExp(r'\s$').hasMatch(prefix)) {
    return prefix + transcript;
  }
  return '$prefix $transcript';
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key, this.initialText, this.onCaptured});
  final String? initialText;
  final ValueChanged<Item>? onCaptured;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  late final _HighlightingController _title;

  /// Recognitions the user turned back into text ("Keep as text"), by
  /// [CaptureToken.key], so they stay unrecognized while typing continues.
  final Set<String> _ignored = {};
  late final TextEditingController _notes;
  final _titleFocus = FocusNode();
  Dictation? _dictation;
  Future<void> _dictationCleanup = Future<void>.value();
  int _dictationGeneration = 0;
  bool _listening = false;
  bool _speechBusy = false;
  bool _dictationFailed = false;
  bool _saving = false;
  bool _savingAndContinuing = false;
  bool _saved = false;
  bool _saveFailed = false;
  int _capturedCount = 0;

  @override
  void initState() {
    super.initState();
    _title = _HighlightingController(text: widget.initialText ?? '');
    // Rebuild on every edit so the parse, highlights, and chips stay live.
    _title.addListener(_onTitleChanged);
    _notes = TextEditingController()..addListener(_onTitleChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _titleFocus.requestFocus();
    });
  }

  void _onTitleChanged() {
    if (mounted) setState(() {});
  }

  /// Quick-capture parse of the current title (ADR 0007). Dates are English
  /// keywords, so they are recognized only when the app language is English;
  /// `@context`, `#project`, and `+tag` work in every language.
  QuickCaptureParse _parse() => parseQuickCapture(
    _title.text,
    now: ref.read(currentTimeProvider),
    contexts: ref.read(contextsProvider).valueOrNull ?? const [],
    projects: ref.read(activeProjectsProvider).valueOrNull ?? const [],
    tags: ref.read(tagsProvider).valueOrNull ?? const [],
    parseDates: AppLocalizations.of(context).localeName.startsWith('en'),
    ignored: _ignored,
  );

  @override
  void dispose() {
    _title.removeListener(_onTitleChanged);
    _title.dispose();
    _notes.removeListener(_onTitleChanged);
    _notes.dispose();
    _titleFocus.dispose();
    unawaited(_cancelDictation());
    super.dispose();
  }

  Future<void> _cancelDictation() {
    // Results from the saved draft must not overwrite the next blank draft.
    _dictationGeneration++;
    final dictation = _dictation;
    _dictation = null;
    if (dictation == null) return _dictationCleanup;
    return _dictationCleanup = _finishDictationCleanup(dictation);
  }

  Future<void> _finishDictationCleanup(Dictation dictation) async {
    try {
      await dictation.cancel();
    } catch (_) {
      // Device speech cleanup must not prevent saving or dismissing a capture.
    }
  }

  void _dictationError() {
    if (!mounted || _saving) return;
    setState(() {
      _listening = false;
      _dictationFailed = true;
    });
    unawaited(_cancelDictation());
  }

  Future<void> _toggleListen() async {
    if (_saving || _speechBusy) return;
    final haptics = ref.read(hapticsEnabledProvider);
    if (haptics) unawaited(HapticFeedback.selectionClick());
    setState(() {
      _speechBusy = true;
      _dictationFailed = false;
    });
    var generation = _dictationGeneration;
    try {
      // A delayed native cancel must finish before a new session can start.
      await _dictationCleanup;
      if (!mounted) return;
      final dictation = _dictation ??= ref.read(dictationFactoryProvider)();
      if (_listening) {
        await dictation.stop();
        if (mounted) setState(() => _listening = false);
      } else {
        generation = ++_dictationGeneration;
        // Transcripts are cumulative per session, so keep what was already
        // typed and append to it instead of replacing the whole title.
        final prefix = _title.text;
        setState(() => _listening = true);
        final started = await dictation.start(
          onText: (text) {
            if (!mounted ||
                _saving ||
                generation != _dictationGeneration ||
                text.isEmpty) {
              return;
            }
            final joined = appendDictation(prefix, text);
            _title.value = TextEditingValue(
              text: joined,
              selection: TextSelection.collapsed(offset: joined.length),
            );
          },
          onStopped: () {
            if (mounted && generation == _dictationGeneration) {
              setState(() => _listening = false);
            }
          },
          onError: () {
            if (generation == _dictationGeneration) _dictationError();
          },
        );
        if (!started && generation == _dictationGeneration) _dictationError();
      }
    } catch (_) {
      if (generation == _dictationGeneration) _dictationError();
    } finally {
      if (mounted) setState(() => _speechBusy = false);
    }
  }

  Future<void> _save({bool continueCapture = false}) async {
    if (_saving || _saved || _speechBusy) return;
    final parsed = _parse();
    final title = parsed.title.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).captureEmptyError)),
      );
      return;
    }
    final notes = _notes.text.trim();
    final capture = ref.read(captureItemProvider);
    final haptics = ref.read(hapticsEnabledProvider);
    setState(() {
      _saving = true;
      _savingAndContinuing = continueCapture;
      _saveFailed = false;
      _listening = false;
    });
    unawaited(_cancelDictation());
    try {
      final item = await capture(
        title: title,
        notes: notes.isEmpty ? null : notes,
        contextId: parsed.contextId,
        projectId: parsed.projectId,
        deferUntil: parsed.deferUntil,
        dueAt: parsed.dueAt,
        tagNames: parsed.tagNames,
      );
      if (!mounted) return;
      widget.onCaptured?.call(item);
      setState(() {
        _capturedCount++;
        _saved = !continueCapture;
        if (continueCapture) {
          _ignored.clear();
          _title.clear();
          _notes.clear();
          _dictationFailed = false;
        }
      });
      if (haptics) unawaited(HapticFeedback.mediumImpact());
      if (continueCapture) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _titleFocus.requestFocus();
        });
      } else {
        Navigator.of(context).pop(item);
      }
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Unsaved typed text that closing the sheet would lose.
  bool get _hasUnsavedText =>
      !_saved &&
      (_title.text.trim().isNotEmpty || _notes.text.trim().isNotEmpty);

  /// Runs when a pop was blocked by [PopScope] (back, barrier tap, or the close
  /// button): confirm before discarding typed text. While a save is in flight
  /// the pop is simply ignored.
  Future<void> _onPopBlocked(bool didPop, Object? result) async {
    if (didPop || _saving) return;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.discardCaptureTitle),
          content: Text(l10n.discardCaptureBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.keepEditing),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.discard),
            ),
          ],
        );
      },
    );
    if (discard == true && mounted && !_saving) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = AppLocalizations.of(context);
    // Watched so the parse refreshes when names load or change.
    final now = ref.watch(currentTimeProvider);
    final contexts = ref.watch(contextsProvider).valueOrNull ?? const [];
    final projects = ref.watch(activeProjectsProvider).valueOrNull ?? const [];
    final tags = ref.watch(tagsProvider).valueOrNull ?? const [];
    final parsed = _parse();
    _title.highlight(parsed.tokens, scheme.primary);
    final englishDates = l10n.localeName.startsWith('en');
    return PopScope(
      canPop: (!_saving || _saved) && !_hasUnsavedText,
      onPopInvokedWithResult: _onPopBlocked,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inbox, color: scheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.captureTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _listening ? l10n.stopDictation : l10n.dictate,
                        onPressed: _saving || _speechBusy
                            ? null
                            : _toggleListen,
                        icon: _speechBusy
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _listening ? Icons.mic : Icons.mic_none,
                                color: _listening
                                    ? scheme.error
                                    : scheme.primary,
                              ),
                      ),
                      IconButton(
                        tooltip: _capturedCount == 0 ? l10n.cancel : l10n.done,
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  if (_capturedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Semantics(
                        liveRegion: true,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l10n.captureAddedCount(_capturedCount),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  TextField(
                    enabled: !_saving,
                    controller: _title,
                    focusNode: _titleFocus,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: l10n.captureHint,
                      border: const OutlineInputBorder(),
                      errorText: _saveFailed ? l10n.saveError : null,
                      errorMaxLines: 3,
                      helperText: _title.text.isEmpty
                          ? (englishDates
                                ? l10n.captureTipDates
                                : l10n.captureTipSigils)
                          : null,
                      helperMaxLines: 3,
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                  if (parsed.tokens.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Semantics(
                        container: true,
                        label: l10n.captureRecognized,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final token in parsed.tokens)
                              _TokenChip(
                                key: ValueKey(token.key),
                                token: token,
                                now: now,
                                contexts: contexts,
                                projects: projects,
                                tags: tags,
                                onKeepAsText: _saving
                                    ? null
                                    : () => setState(
                                        () => _ignored.add(token.key),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    enabled: !_saving,
                    controller: _notes,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.captureNotesHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (_dictationFailed) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.dictationUnavailable,
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _CaptureActions(
                    disabled: _saving || _speechBusy,
                    saving: _saving,
                    continuing: _savingAndContinuing,
                    onContinue: () => _save(continueCapture: true),
                    onSubmit: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The title field's controller: draws recognized quick-capture tokens in
/// the accent color so the user sees exactly which words became a date,
/// context, or project. Falls back to plain text while an IME is composing,
/// where span offsets would fight the composing underline.
class _HighlightingController extends TextEditingController {
  _HighlightingController({super.text});

  List<CaptureToken> _tokens = const [];
  Color _color = Colors.transparent;

  /// Sets the spans to draw. Called from build, before the field paints, so
  /// it updates fields without notifying listeners.
  void highlight(List<CaptureToken> tokens, Color color) {
    _tokens = tokens;
    _color = color;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composing = value.composing;
    final spans = [..._tokens]..sort((a, b) => a.start.compareTo(b.start));
    if (spans.isEmpty ||
        (withComposing && composing.isValid && !composing.isCollapsed) ||
        spans.any((t) => t.end > text.length)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final accent = (style ?? const TextStyle()).copyWith(
      color: _color,
      fontWeight: FontWeight.w600,
      backgroundColor: _color.withValues(alpha: 0.12),
    );
    final children = <TextSpan>[];
    var at = 0;
    for (final t in spans) {
      if (t.start < at) continue;
      if (t.start > at) {
        children.add(TextSpan(text: text.substring(at, t.start)));
      }
      children.add(
        TextSpan(text: text.substring(t.start, t.end), style: accent),
      );
      at = t.end;
    }
    if (at < text.length) children.add(TextSpan(text: text.substring(at)));
    return TextSpan(style: style, children: children);
  }
}

/// States one recognized interpretation; its delete action ("Keep as text")
/// puts the words back into the title.
class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    required this.now,
    required this.contexts,
    required this.projects,
    required this.tags,
    required this.onKeepAsText,
    super.key,
  });

  final CaptureToken token;

  /// App-clock time, so the year is shown exactly when the date falls in
  /// another year of the same clock the parser used.
  final DateTime now;
  final List<GtdContext> contexts;
  final List<Project> projects;
  final List<Tag> tags;
  final VoidCallback? onKeepAsText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, label) = switch (token.kind) {
      CaptureTokenKind.date => (
        token.isDue ? Icons.event : Icons.schedule_send_outlined,
        token.isDue
            ? l10n.dueOnDate(_date(l10n))
            : l10n.startsOnDate(_date(l10n)),
      ),
      CaptureTokenKind.context => (
        Icons.label_outline,
        contexts.where((c) => c.id == token.contextId).firstOrNull?.name ??
            token.source,
      ),
      CaptureTokenKind.project => (
        Icons.folder_outlined,
        l10n.captureChipProject(
          projects.where((p) => p.id == token.projectId).firstOrNull?.title ??
              token.source,
        ),
      ),
      CaptureTokenKind.tag => _tag(l10n),
    };
    return InputChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onDeleted: onKeepAsText,
      deleteIcon: const Icon(Icons.close, size: 18),
      deleteButtonTooltipMessage: l10n.captureKeepAsText,
    );
  }

  (IconData, String) _tag(AppLocalizations l10n) {
    final tag = tags.where((t) => t.id == token.tagId).firstOrNull;
    if (tag == null) {
      return (Icons.sell_outlined, l10n.captureChipNewTag(token.tagName!));
    }
    return (
      tag.isPerson ? Icons.person_outline : Icons.sell_outlined,
      tag.name,
    );
  }

  String _date(AppLocalizations l10n) {
    final date = token.date!;
    return (date.year == now.year
            ? DateFormat.MMMEd(l10n.dateLocaleName)
            : DateFormat.yMMMEd(l10n.dateLocaleName))
        .format(date);
  }
}

/// Equal buttons when both labels fit; full-width stacking keeps translations
/// and accessibility text readable without shrinking fonts or clipping labels.
class _CaptureActions extends StatelessWidget {
  const _CaptureActions({
    required this.disabled,
    required this.saving,
    required this.continuing,
    required this.onContinue,
    required this.onSubmit,
  });

  final bool disabled;
  final bool saving;
  final bool continuing;
  final VoidCallback onContinue;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: 15.5,
      fontWeight: FontWeight.w600,
    );
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    Widget progress() => const SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    final addMore = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(padding: padding, textStyle: textStyle),
      onPressed: disabled ? null : onContinue,
      icon: saving && continuing
          ? progress()
          : const Icon(Icons.playlist_add, size: 18),
      label: Text(l10n.captureAddContinue),
    );
    final finish = FilledButton.icon(
      style: FilledButton.styleFrom(padding: padding, textStyle: textStyle),
      onPressed: disabled ? null : onSubmit,
      icon: saving && !continuing
          ? progress()
          : const Icon(Icons.add, size: 18),
      label: Text(l10n.captureSubmit),
    );
    double requiredWidth(String label) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: Directionality.of(context),
        locale: Localizations.localeOf(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      // Two 16px insets, icon, gap, and a little border/rounding tolerance.
      final width = painter.width + 60;
      painter.dispose();
      return width;
    }

    final continueWidth = requiredWidth(l10n.captureAddContinue);
    final finishWidth = requiredWidth(l10n.captureSubmit);
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - 12) / 2;
        if (buttonWidth >= continueWidth && buttonWidth >= finishWidth) {
          return Row(
            children: [
              Expanded(child: addMore),
              const SizedBox(width: 12),
              Expanded(child: finish),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [addMore, const SizedBox(height: 12), finish],
        );
      },
    );
  }
}

/// Full-screen version used by route-based capture (e.g. share extension).
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.initialText});
  final String? initialText;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  @override
  void initState() {
    super.initState();
    // Opening a route is a one-time effect. Rebuilding during a resize or
    // appearance change must not stack another sheet over the current draft.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final captured = await showCaptureSheet(
        context,
        initialText: widget.initialText,
      );
      if (mounted) {
        Navigator.of(context).pop(captured);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: ColoredBox(color: Colors.transparent));
}
