import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../domain/entities/entities.dart';

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
    final initial =
        await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      await _handle(initial);
      unawaited(ReceiveSharingIntent.instance.reset());
    }
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(_handle);
  }

  Future<void> _handle(List<SharedMediaFile> shared) async {
    final ids = ref.read(idGeneratorProvider);
    final clock = ref.read(clockProvider);
    final repo = ref.read(itemRepositoryProvider);
    for (final m in shared) {
      final text = (m.path).trim();
      if (text.isEmpty) continue;
      final now = clock.now();
      await repo.upsert(Item(
        id: ids.newId(),
        title: text.length > 120 ? '${text.substring(0, 117)}…' : text,
        notes: text.length > 120 ? text : null,
        status: ItemStatus.inbox,
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (!mounted || shared.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${shared.length} to inbox')),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
