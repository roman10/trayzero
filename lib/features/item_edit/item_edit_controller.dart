import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../application/save_item.dart';
import '../../domain/entities/entities.dart';

/// State container for the Item Edit screen.
///
/// Holds the loaded [Item] as `AsyncValue<Item>`. UI sections call
/// [updateDraft] to mutate the draft locally; [commit] flushes the draft
/// through the [SaveItem] use case so notification reconciliation happens
/// in one place. The Save button is removed; the screen calls [commit]
/// from text-field blur handlers and from immediate-select pickers.
class ItemEditController extends FamilyAsyncNotifier<Item, String> {
  bool _dirty = false;
  bool get hasUnsavedDraft => _dirty;

  @override
  Future<Item> build(String id) async {
    final item = await ref.read(itemRepositoryProvider).getById(id);
    if (item == null) {
      throw StateError('Item $id not found');
    }
    return item;
  }

  /// Locally update the draft. Does not write to the DB. UI should call
  /// [commit] to persist; text fields commit on blur, immediate-selection
  /// pickers commit straight after calling this.
  void updateDraft(Item Function(Item current) update) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    _dirty = true;
    state = AsyncData(update(cur));
  }

  /// Persist the current draft through [SaveItem]. Idempotent.
  /// Returns `true` when a write actually happened so the UI can flash a
  /// "Saved" indicator only on real saves.
  Future<bool> commit() async {
    final cur = state.valueOrNull;
    if (cur == null || !_dirty) return false;
    final saved = await ref.read(saveItemProvider).call(cur);
    _dirty = false;
    state = AsyncData(saved);
    return true;
  }

  /// Persist the current draft regardless of [_dirty] — used when callers
  /// want to force a save (e.g. immediate-selection pickers).
  Future<bool> commitNow() async {
    _dirty = true;
    return commit();
  }

  Future<void> delete() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    await ref.read(deleteItemProvider).call(cur.id);
  }

  Future<void> complete() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    await ref.read(completeItemProvider).call(cur.id);
  }

  Future<void> reopen() async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    await ref.read(reopenItemProvider).call(cur.id);
  }
}

final itemEditControllerProvider =
    AsyncNotifierProvider.family<ItemEditController, Item, String>(
  ItemEditController.new,
);
