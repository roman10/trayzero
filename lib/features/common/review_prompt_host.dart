import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../application/review_prompt_scheduler.dart';

/// Observes activity without consuming input or changing focus.
class ReviewPromptHost extends ConsumerStatefulWidget {
  const ReviewPromptHost({
    required this.router,
    required this.child,
    super.key,
  });
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<ReviewPromptHost> createState() => _ReviewPromptHostState();
}

class _ReviewPromptHostState extends ConsumerState<ReviewPromptHost>
    with WidgetsBindingObserver {
  void _recordDay() {
    unawaited(
      ref.read(recordAppActiveDayProvider).call().catchError((Object _) {}),
    );
  }

  void _cancel() => ref.read(reviewPromptSchedulerProvider).cancel();

  void _interact() {
    _cancel();
    _recordDay();
  }

  bool _key(KeyEvent event) {
    if (event is KeyDownEvent) _interact();
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_key);
    widget.router.routerDelegate.addListener(_cancel);
    final state = WidgetsBinding.instance.lifecycleState;
    ref
        .read(reviewPromptSchedulerProvider)
        .setForeground(state == null || state == AppLifecycleState.resumed);
    _recordDay();
  }

  @override
  void didUpdateWidget(covariant ReviewPromptHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_cancel);
      widget.router.routerDelegate.addListener(_cancel);
      _cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref
        .read(reviewPromptSchedulerProvider)
        .setForeground(state == AppLifecycleState.resumed);
    if (state == AppLifecycleState.resumed) _recordDay();
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_cancel);
    HardwareKeyboard.instance.removeHandler(_key);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (_) => _interact(),
    onPointerSignal: (_) => _interact(),
    child: widget.child,
  );
}
