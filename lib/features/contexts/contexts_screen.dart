import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../application/providers.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

const _iconChoices = <String, IconData>{
  'label': Icons.label_outline,
  'phone': Icons.phone,
  'computer': Icons.computer,
  'shopping_bag': Icons.shopping_bag_outlined,
  'home': Icons.home_outlined,
  'business_center': Icons.business_center_outlined,
  'public': Icons.public,
  'hourglass_top': Icons.hourglass_top_outlined,
  'directions_car': Icons.directions_car_outlined,
  'menu_book': Icons.menu_book_outlined,
  'fitness_center': Icons.fitness_center,
  'coffee': Icons.local_cafe_outlined,
};

const _colorChoices = <int>[
  0xFF1E88E5,
  0xFF6D4C41,
  0xFFE53935,
  0xFF43A047,
  0xFF8E24AA,
  0xFF00897B,
  0xFFFB8C00,
  0xFF3949AB,
  0xFFD81B60,
  0xFF546E7A,
];

IconData iconForName(String name) =>
    _iconChoices[name] ?? Icons.label_outline;

class ContextsScreen extends ConsumerWidget {
  const ContextsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ctxs = ref.watch(contextsProvider);
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contextsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editContext(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newContext),
      ),
      body: ctxs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.contextsEmptyMessage,
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
              final c = list[i];
              final tint = Color(c.color).onSurfaceOf(brightness);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tint.withValues(alpha: 0.18),
                  foregroundColor: tint,
                  child: Icon(iconForName(c.icon)),
                ),
                title: Text(c.name),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      await _editContext(context, ref, existing: c);
                    } else if (v == 'delete') {
                      final dialogL10n = AppLocalizations.of(context);
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                              dialogL10n.deleteContextConfirmTitle(c.name)),
                          content: Text(dialogL10n.deleteContextWarning),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: Text(dialogL10n.cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: Text(dialogL10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await ref
                            .read(contextRepositoryProvider)
                            .delete(c.id);
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
                onTap: () => _editContext(context, ref, existing: c),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editContext(
    BuildContext context,
    WidgetRef ref, {
    GtdContext? existing,
  }) async {
    final l10n = AppLocalizations.of(context);
    final ctrl =
        TextEditingController(text: existing?.name ?? '@');
    var icon = existing?.icon ?? 'label';
    var color = existing?.color ?? _colorChoices.first;
    final brightness = Theme.of(context).brightness;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? l10n.newContext : l10n.editContext,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.nameLabel),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.iconLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in _iconChoices.entries)
                        InkWell(
                          onTap: () => setState(() => icon = entry.key),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: icon == entry.key
                                  ? Color(color)
                                      .onSurfaceOf(brightness)
                                      .withValues(alpha: 0.2)
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                              border: icon == entry.key
                                  ? Border.all(
                                      color: Color(color)
                                          .onSurfaceOf(brightness),
                                      width: 2)
                                  : null,
                            ),
                            child: Icon(entry.value,
                                color: Color(color).onSurfaceOf(brightness)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.colorLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _colorChoices)
                        InkWell(
                          onTap: () => setState(() => color = c),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: color == c
                                  ? Border.all(
                                      width: 3,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: Text(l10n.save),
                        onPressed: () =>
                            Navigator.pop(context, true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (result != true) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    final final_ = (existing ??
            GtdContext(
              id: ref.read(idGeneratorProvider).newId(),
              name: name,
              icon: icon,
              color: color,
            ))
        .copyWith(name: name, icon: icon, color: color);
    await ref.read(contextRepositoryProvider).upsert(final_);
  }
}
