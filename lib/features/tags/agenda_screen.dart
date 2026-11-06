import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/complete_with_undo.dart';
import '../common/focus_star.dart';
import '../common/item_card.dart';

/// One person's Agenda (ADR 0010): what to discuss with them, checked off
/// during the conversation, plus Waiting For Items that name them.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({required this.tagId, super.key});

  final String tagId;

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  final _add = TextEditingController();
  final _addFocus = FocusNode();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _add.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _add.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  /// Adds the typed point and keeps the field focused for the next one.
  Future<void> _submit() async {
    final title = _add.text.trim();
    if (title.isEmpty || _adding) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _adding = true);
    try {
      await ref.read(addAgendaItemProvider).call(widget.tagId, title);
      _add.clear();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveError)));
    } finally {
      if (mounted) {
        setState(() => _adding = false);
        _addFocus.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!ref.watch(tagsProvider).hasValue) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final agenda = ref
        .watch(agendasProvider)
        .where((a) => a.person.id == widget.tagId)
        .firstOrNull;
    if (agenda == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.agendaNotFound, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final name = agenda.person.name;
    Widget card(Item item) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ItemCard(
        item: item,
        hiddenTagId: widget.tagId,
        onTap: () => context.push('/item/${item.id}'),
        onComplete: () => completeWithUndo(context, ref, item.id),
        onToggleFocus: () => toggleTodayFocus(context, ref, item),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _add,
            focusNode: _addFocus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.agendaAddHint(name),
              suffixIcon: IconButton(
                tooltip: l10n.agendaAddTooltip,
                icon: const Icon(Icons.add),
                onPressed: _add.text.trim().isEmpty || _adding ? null : _submit,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          if (agenda.count == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.agendaEmpty(name),
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          for (final item in agenda.tagged) card(item),
          if (agenda.waitingOn.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Semantics(
                header: true,
                child: Text(
                  l10n.waitingOnPerson(name),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            for (final item in agenda.waitingOn) card(item),
          ],
        ],
      ),
    );
  }
}
