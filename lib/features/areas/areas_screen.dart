import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

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
        error: (e, _) => Center(child: Text('Error: $e')),
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
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = list[i];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.flag_outlined),
                ),
                title: Text(a.name),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      await _editArea(context, ref, area: a);
                    } else if (v == 'delete') {
                      final dialogL10n = AppLocalizations.of(context);
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              dialogL10n.deleteAreaConfirmTitle(a.name)),
                          content: Text(dialogL10n.deleteAreaWarning),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(dialogL10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(dialogL10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref.read(areaRepositoryProvider).delete(a.id);
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.rename)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
                onTap: () => _editArea(context, ref, area: a),
              );
            },
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
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: area?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(area == null ? l10n.newArea : l10n.renameArea),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.areaNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(context, v);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (name == null) return;
    final updated = area == null
        ? Area(id: ref.read(idGeneratorProvider).newId(), name: name)
        : Area(id: area.id, name: name);
    await ref.read(areaRepositoryProvider).upsert(updated);
  }
}
