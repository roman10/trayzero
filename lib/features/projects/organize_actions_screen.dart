import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/empty_state.dart';
import 'project_picker.dart';

/// Bulk "organize" pass: every next action that belongs to no project,
/// multi-selected and filed into one project in a single sweep. The inverse
/// of clarifying items one-by-one — useful after a burst of quick captures.
class OrganizeActionsScreen extends ConsumerStatefulWidget {
  const OrganizeActionsScreen({super.key});

  @override
  ConsumerState<OrganizeActionsScreen> createState() =>
      _OrganizeActionsScreenState();
}

class _OrganizeActionsScreenState extends ConsumerState<OrganizeActionsScreen> {
  final _selected = <String>{};

  Future<void> _assign(List<Item> loose) async {
    final picked = loose.where((i) => _selected.contains(i.id)).toList();
    if (picked.isEmpty) return;
    final pick = await showProjectPicker(context, ref, allowNone: false);
    if (pick == null) return;
    final projectId = switch (pick) {
      ProjectPickNone() => null,
      ProjectPickId(:final id) => id,
    };
    if (projectId == null) return;
    final move = ref.read(moveItemToProjectProvider);
    for (final a in picked) {
      await move(a, projectId);
    }
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).filedItemsSnackbar(picked.length),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loose = (ref.watch(nextActionsProvider).valueOrNull ?? const <Item>[])
        .where((i) => i.projectId == null)
        .toList();
    // Selections that no longer match (item moved/completed elsewhere) are
    // pruned so the count and the assign sweep never disagree.
    _selected.removeWhere((id) => !loose.any((i) => i.id == id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.organizeActionsTitle),
        actions: [
          if (loose.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                if (_selected.length == loose.length) {
                  _selected.clear();
                } else {
                  _selected
                    ..clear()
                    ..addAll(loose.map((i) => i.id));
                }
              }),
              child: Text(_selected.length == loose.length
                  ? l10n.selectNone
                  : l10n.selectAll),
            ),
        ],
      ),
      body: loose.isEmpty
          ? EmptyState(
              icon: Icons.inbox_outlined,
              title: l10n.organizeEmptyTitle,
              message: l10n.organizeEmptyMessage,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
              itemCount: loose.length,
              itemBuilder: (context, i) {
                final a = loose[i];
                final sel = _selected.contains(a.id);
                return CheckboxListTile(
                  value: sel,
                  title: Text(a.title),
                  subtitle: (a.notes != null && a.notes!.isNotEmpty)
                      ? Text(
                          a.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _selected.add(a.id);
                    } else {
                      _selected.remove(a.id);
                    }
                  }),
                );
              },
            ),
      floatingActionButton: _selected.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _assign(loose),
              icon: const Icon(Icons.drive_file_move_outlined),
              label: Text(l10n.assignToProject(_selected.length)),
            ),
    );
  }
}
