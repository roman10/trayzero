import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../features/capture/capture_sheet.dart';
import '../features/common/keyboard_shortcut_actions.dart';

/// App commands are independent of the current navigation layout.
class AppKeyboardShortcuts extends StatelessWidget {
  const AppKeyboardShortcuts({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    final search = searchShortcut.accepts(event, keyboard);
    if (!search && !captureShortcut.accepts(event, keyboard)) {
      return KeyEventResult.ignored;
    }

    final context = _focusedPageContext();
    if (context == null || router.state.uri.path == '/onboarding') {
      return KeyEventResult.ignored;
    }

    if (search) {
      // Search handles its own focus. The pending URI also covers a second
      // key press before the first push has been built.
      if (router.state.uri.path != '/search' &&
          router.routeInformationProvider.value.uri.path != '/search') {
        unawaited(router.push('/search'));
      }
    } else {
      unawaited(showCaptureSheet(context));
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: _handleKey,
    child: child,
  );
}

// A tab can still be current in its nested navigator behind a root dialog.
// Walk the parent routes as well before dispatching a page-level command.
BuildContext? _focusedPageContext() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null || !context.mounted) return null;
  var route = ModalRoute.of(context);
  if (route == null) return null;
  while (route != null) {
    if (route is! PageRoute || !route.isCurrent || route.fullscreenDialog) {
      return null;
    }
    final navigator = route.navigator;
    if (navigator == null) return null;
    route = ModalRoute.of(navigator.context);
  }
  return context;
}
