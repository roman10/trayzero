import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';
import '../../l10n/gen/app_localizations.dart';

/// Wraps a child and listens to inbound share intents. Any incoming text
/// is silently added to the Inbox and a snackbar is shown.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Subscribe before awaiting cold-start media: warm shares can arrive while
    // that platform call or the initial database write is still in flight.
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(_handle);
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (!mounted) return;
    if (initial.isNotEmpty) {
      await _handle(initial);
      unawaited(ReceiveSharingIntent.instance.reset());
    }
  }

  Future<void> _handle(List<SharedMediaFile> shared) async {
    final ids = ref.read(idGeneratorProvider);
    final clock = ref.read(clockProvider);
    final repo = ref.read(itemRepositoryProvider);
    for (final m in shared) {
      final text = (m.path).trim();
      if (text.isEmpty) continue;
      final now = clock.now();
      await repo.upsert(
        Item(
          id: ids.newId(),
          title: _shareTitle(text),
          notes: text.length > 120 ? text : null,
          status: ItemStatus.inbox,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    if (!mounted || shared.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).sharedAddedToInbox(shared.length),
        ),
      ),
    );
  }

  /// Leave room for the ellipsis without splitting a UTF-16 surrogate pair.
  /// SQLite would otherwise replace the orphaned surrogate with U+FFFD.
  static String _shareTitle(String text) {
    if (text.length <= 120) return text;
    var end = 117;
    final unit = text.codeUnitAt(end - 1);
    if (unit >= 0xD800 && unit <= 0xDBFF) end--;
    return '${text.substring(0, end)}…';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
