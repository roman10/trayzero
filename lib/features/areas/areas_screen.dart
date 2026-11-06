import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/error_view.dart';
import '../settings/settings_tiles.dart';

/// "Areas of Focus" — Horizons of Focus level 2.
///
/// Areas are stable spheres of responsibility (Health, Career, Family, …)
/// rather than time-bound projects. They give the projects screen an extra
/// grouping axis above the status grouping.
class AreasScreen extends ConsumerWidget {
  const AreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final areas = ref.watch(areasProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.areasTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'areas-fab',
        onPressed: () => _editArea(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newArea),
      ),
      body: areas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorView(
          error: e,
          stackTrace: st,
          onRetry: () => ref.invalidate(areasProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.areasEmptyMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            children: [
              SettingsGroup(
                children: [
                  for (final a in list)
                    SettingsRow(
                      icon: Icons.flag_outlined,
                      title: a.name,
                      chevron: false,
                      onTap: () => _editArea(context, ref, area: a),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editArea(
    BuildContext context,
    WidgetRef ref, {
    Area? area,
  }) async {
    final edit = await showModalBottomSheet<_AreaEdit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _AreaSheet(existing: area),
    );
    if (edit == null || !context.mounted) return;
    if (edit.delete) {
      final ok = await _confirmDelete(context, area!);
      if (ok == true) await ref.read(areaRepositoryProvider).delete(area.id);
      return;
    }
    final updated = area == null
        ? Area(id: ref.read(idGeneratorProvider).newId(), name: edit.name)
        : Area(id: area.id, name: edit.name);
    await ref.read(areaRepositoryProvider).upsert(updated);
  }
}

/// What the edit sheet returns: delete, or save with this name.
typedef _AreaEdit = ({bool delete, String name});

/// Name field for a new or existing area, with Delete when editing.
class _AreaSheet extends StatefulWidget {
  const _AreaSheet({this.existing});

  final Area? existing;

  @override
  State<_AreaSheet> createState() => _AreaSheetState();
}

class _AreaSheetState extends State<_AreaSheet> {
  late final _name = TextEditingController(text: widget.existing?.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _close({required bool delete}) => Navigator.pop<_AreaEdit>(context, (
    delete: delete,
    name: _name.text.trim(),
  ));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _name.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l10n.newArea : l10n.renameArea,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.areaNameHint),
              onChanged: (_) => setState(() {}),
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

Future<bool?> _confirmDelete(BuildContext context, Area area) =>
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.deleteAreaConfirmTitle(area.name)),
          content: Text(l10n.deleteAreaWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
