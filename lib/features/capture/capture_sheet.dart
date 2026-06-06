import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';

/// Shows a friction-free capture sheet. Returns the captured [Item] if any.
Future<Item?> showCaptureSheet(BuildContext context, {String? initialText}) {
  return showModalBottomSheet<Item>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (_) => CaptureSheet(initialText: initialText),
  );
}

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key, this.initialText});
  final String? initialText;

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  final _titleFocus = FocusNode();
  final _speech = stt.SpeechToText();
  bool _listening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialText ?? '');
    _notes = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening' || status == 'done') {
          setState(() => _listening = false);
        }
      },
    );
    if (mounted) setState(() => _speechAvailable = ok);
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _titleFocus.dispose();
    if (_listening) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _toggleListen() async {
    if (!_speechAvailable) return;
    final haptics = ref.read(hapticsEnabledProvider);
    if (haptics) unawaited(HapticFeedback.selectionClick());
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        final text = result.recognizedWords;
        if (text.isEmpty) return;
        if (_title.text.isEmpty) {
          _title.text = text;
        } else {
          _title.text = text;
        }
        _title.selection =
            TextSelection.collapsed(offset: _title.text.length);
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).captureEmptyError)),
      );
      return;
    }
    final now = ref.read(clockProvider).now();
    final item = Item(
      id: ref.read(idGeneratorProvider).newId(),
      title: title,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      status: ItemStatus.inbox,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(itemRepositoryProvider).upsert(item);
    if (ref.read(hapticsEnabledProvider)) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (!mounted) return;
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
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
                Text(
                  l10n.captureTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_speechAvailable)
                  IconButton(
                    tooltip:
                        _listening ? l10n.stopDictation : l10n.dictate,
                    onPressed: _toggleListen,
                    icon: Icon(
                      _listening ? Icons.mic : Icons.mic_none,
                      color: _listening ? scheme.error : scheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _title,
              focusNode: _titleFocus,
              autofocus: true,
              textInputAction: TextInputAction.next,
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.captureHint,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.captureNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.captureSubmit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen version used by route-based capture (e.g. share extension).
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, this.initialText});
  final String? initialText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final captured =
          await showCaptureSheet(context, initialText: initialText);
      if (context.mounted) {
        Navigator.of(context).pop(captured);
      }
    });
    return const Scaffold(
      body: ColoredBox(color: Colors.transparent),
    );
  }
}
