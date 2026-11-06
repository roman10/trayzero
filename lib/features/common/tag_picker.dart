import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../domain/entities/entities.dart';
import '../../domain/tags.dart';
import '../../l10n/gen/app_localizations.dart';

/// Icon for a tag: a person keeps an Agenda (ADR 0010).
IconData tagIcon(Tag tag) =>
    tag.isPerson ? Icons.person_outline : Icons.sell_outlined;

/// An Item's tags (ADR 0010): one removable chip per tag and a small "Add
/// tag" chip that opens [showTagPicker]. Changes save immediately and never
/// touch the Item's other fields.
class ItemTagsField extends ConsumerWidget {
  const ItemTagsField({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final all = ref.watch(tagsProvider).valueOrNull ?? const [];
    final ids = ref.watch(itemTagIdsProvider).valueOrNull?[itemId] ?? const [];
    final selected = [
      for (final t in all)
        if (ids.contains(t.id)) t,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final t in selected)
          InputChip(
            avatar: Icon(tagIcon(t), size: 18),
            label: Text(t.name),
            tooltip: t.isPerson
                ? l10n.personChipSemantics(t.name)
                : l10n.tagChipSemantics(t.name),
            deleteButtonTooltipMessage: l10n.removeTagTooltip(t.name),
            onDeleted: () => ref.read(manageTagsProvider).setItemTags(itemId, [
              for (final id in ids)
                if (id != t.id) id,
            ]),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: Text(l10n.addTag),
          onPressed: () => showTagPicker(context, itemId: itemId),
        ),
      ],
    );
  }
}

/// Bottom sheet that toggles tags on one Item, with a search field that also
/// creates a tag (or a person) from what was typed. Every toggle saves at
/// once, so dismissing the sheet never loses a choice.
Future<void> showTagPicker(BuildContext context, {required String itemId}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _TagPickerSheet(itemId: itemId),
    );

class _TagPickerSheet extends ConsumerStatefulWidget {
  const _TagPickerSheet({required this.itemId});

  final String itemId;

  @override
  ConsumerState<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<_TagPickerSheet> {
  final _query = TextEditingController();

  /// Local copy so a toggle shows before the database round trip.
  late final Set<String> _selected = {
    ...?ref.read(itemTagIdsProvider).valueOrNull?[widget.itemId],
  };

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _write() =>
      ref.read(manageTagsProvider).setItemTags(widget.itemId, {..._selected});

  void _toggle(Tag tag) {
    setState(() {
      if (!_selected.remove(tag.id)) _selected.add(tag.id);
    });
    _write();
  }

  Future<void> _create({required bool isPerson}) async {
    final tag = await ref
        .read(manageTagsProvider)
        .obtain(_query.text, isPerson: isPerson);
    if (tag == null || !mounted) return;
    setState(() => _selected.add(tag.id));
    _query.clear();
    await _write();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final all = ref.watch(tagsProvider).valueOrNull ?? const [];
    final key = tagKey(_query.text);
    final matches = key.isEmpty
        ? all
        : [
            for (final t in all)
              if (t.name.toLowerCase().contains(key)) t,
          ];
    final typed = cleanTagName(_query.text);
    final canCreate = typed != null && findTagByName(all, typed) == null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _query,
                autofocus: true,
                maxLength: maxTagNameLength,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: l10n.tagPickerHint,
                  prefixIcon: const Icon(Icons.search),
                  counterText: '',
                ),
                onSubmitted: (_) {
                  if (canCreate) {
                    _create(isPerson: false);
                  } else if (matches.length == 1) {
                    _toggle(matches.single);
                    _query.clear();
                  }
                },
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  if (canCreate) ...[
                    ListTile(
                      leading: Icon(Icons.add, color: scheme.primary),
                      title: Text(l10n.tagCreate(typed)),
                      onTap: () => _create(isPerson: false),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person_add_alt_outlined,
                        color: scheme.primary,
                      ),
                      title: Text(l10n.tagCreatePerson(typed)),
                      onTap: () => _create(isPerson: true),
                    ),
                  ],
                  for (final t in matches)
                    CheckboxListTile(
                      value: _selected.contains(t.id),
                      onChanged: (_) => _toggle(t),
                      secondary: Icon(tagIcon(t)),
                      title: Text(t.name),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
