import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/manage_tags.dart';
import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/tags.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
import '../common/tag_picker.dart';
import '../settings/settings_tiles.dart';

/// More → Organization → Tags & people (ADR 0010): rename, merge (by renaming
/// onto an existing name), delete, and mark tags as people.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tags = ref.watch(tagsProvider);
    final counts = ref.watch(tagOpenCountsProvider).valueOrNull ?? const {};
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tagsAndPeopleLabel)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTag(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newTag),
      ),
      body: tags.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorView(
          error: e,
          stackTrace: st,
          onRetry: () => ref.invalidate(tagsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.tagsEmptyMessage, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            children: [
              SettingsGroup(
                children: [
                  for (final t in list)
                    SettingsRow(
                      icon: tagIcon(t),
                      title: t.name,
                      subtitle: l10n.tagOpenItems(counts[t.id] ?? 0),
                      chevron: false,
                      onTap: () => _editTag(context, ref, existing: t),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// What the edit sheet returns: delete, or save with these values.
typedef _TagEdit = ({bool delete, String name, bool isPerson});

Future<void> _editTag(
  BuildContext context,
  WidgetRef ref, {
  Tag? existing,
}) async {
  final edit = await showModalBottomSheet<_TagEdit>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _TagSheet(existing: existing),
  );
  if (edit == null || !context.mounted) return;
  final manage = ref.read(manageTagsProvider);
  if (edit.delete) {
    await _confirmDelete(context, ref, existing!);
    return;
  }
  if (existing == null) {
    await manage.obtain(edit.name, isPerson: edit.isPerson);
    return;
  }
  switch (await manage.rename(existing.id, edit.name)) {
    case TagRenamed():
      await manage.setPerson(existing.id, edit.isPerson);
    case TagNameTaken(existing: final target):
      if (!context.mounted) return;
      final merge = await _confirmMerge(context, existing.name, target.name);
      if (merge != true) return;
      await manage.merge(existing.id, target.id);
      if (edit.isPerson) await manage.setPerson(target.id, true);
    case TagNameInvalid():
      break;
  }
}

/// Name and Person switch for a new or existing tag.
class _TagSheet extends StatefulWidget {
  const _TagSheet({this.existing});

  final Tag? existing;

  @override
  State<_TagSheet> createState() => _TagSheetState();
}

class _TagSheetState extends State<_TagSheet> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late bool _isPerson = widget.existing?.isPerson ?? false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _close({required bool delete}) => Navigator.pop<_TagEdit>(context, (
    delete: delete,
    name: _name.text,
    isPerson: _isPerson,
  ));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = cleanTagName(_name.text) != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.newTag : l10n.editTag,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: widget.existing == null,
              maxLength: maxTagNameLength,
              decoration: InputDecoration(labelText: l10n.nameLabel),
              onChanged: (_) => setState(() {}),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.person_outline),
              title: Text(l10n.tagPersonSwitch),
              subtitle: Text(l10n.tagPersonSwitchHint),
              value: _isPerson,
              onChanged: (v) => setState(() => _isPerson = v),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              children: [
                if (widget.existing != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                    onPressed: () => _close(delete: true),
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l10n.save),
                  onPressed: valid ? () => _close(delete: false) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmMerge(
  BuildContext context,
  String source,
  String target,
) => showDialog<bool>(
  context: context,
  builder: (dialogContext) {
    final l10n = AppLocalizations.of(dialogContext);
    return AlertDialog(
      title: Text(l10n.tagMergeTitle),
      content: Text(l10n.tagMergeBody(source, target)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.tagMergeAction),
        ),
      ],
    );
  },
);

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Tag tag,
) async {
  final count = ref.read(tagOpenCountsProvider).valueOrNull?[tag.id] ?? 0;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(l10n.deleteTagConfirmTitle(tag.name)),
        content: Text(l10n.deleteTagConfirmBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );
  if (ok == true) await ref.read(manageTagsProvider).delete(tag.id);
}
