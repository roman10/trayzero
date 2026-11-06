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
class ItemEditController extends AutoDisposeFamilyAsyncNotifier<Item, String> {
  bool _dirty = false;
  int _revision = 0;
  Future<bool>? _pendingCommit;
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
    _revision++;
    state = AsyncData(update(cur));
  }

  /// Persist the current draft through [SaveItem]. Idempotent.
  /// Returns `true` when a write actually happened so the UI can flash a
  /// "Saved" indicator only on real saves.
  Future<bool> commit() {
    final pending = _pendingCommit;
    if (pending != null) return pending;
    // Back navigation flushes the draft while the screen is leaving. Keep
    // this visit alive until all revisions finish, including reminder IO;
    // the next visit must then load current database state.
    final saving = ref.keepAlive();
    return _pendingCommit = _flushDraft().whenComplete(() {
      _pendingCommit = null;
      saving.close();
    });
  }

  Future<bool> _flushDraft() async {
    var wrote = false;
    while (_dirty) {
      final cur = state.valueOrNull;
      if (cur == null) break;
      final revision = _revision;
      final saved = await ref.read(saveItemProvider).call(cur);
      wrote = true;
      // Edits made during the await remain dirty and are saved next. Never
      // replace a newer draft with the result of an older save.
      if (revision == _revision) {
        _dirty = false;
        state = AsyncData(saved);
      }
    }
    return wrote;
  }

  /// Persist the current draft regardless of [_dirty] — used when callers
  /// want to force a save (e.g. immediate-selection pickers).
  Future<bool> commitNow() async {
    _dirty = true;
    _revision++;
    return commit();
  }

  Future<void> delete() async {
    await commit();
    final cur = state.valueOrNull;
    if (cur == null) return;
    await ref.read(deleteItemProvider).call(cur.id);
  }

  /// Completes the item; returns the id of the recurrence instance this
  /// spawned, if any, so the caller can offer Undo.
  Future<String?> complete() async {
    await commit();
    final cur = state.valueOrNull;
    if (cur == null) return null;
    return ref.read(completeItemProvider).call(cur.id);
  }

  Future<void> reopen() async {
    await commit();
    final cur = state.valueOrNull;
    if (cur == null) return;
    await ref.read(reopenItemProvider).call(cur.id);
  }
}

final itemEditControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ItemEditController, Item, String>(ItemEditController.new);
