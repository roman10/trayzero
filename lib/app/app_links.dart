import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/engage/today_controller.dart';
import 'router.dart';

/// Where a `cleartray://` link leads (ADR 0009).
class AppLinkTarget {
  const AppLinkTarget(
    this.location, {
    this.anchor = '/inbox',
    this.showToday = false,
  });

  /// Router location to open.
  final String location;

  /// Shell tab placed beneath a detail [location] so closing it lands
  /// somewhere sensible.
  final String anchor;

  /// Select the Today view of the Do tab first.
  final bool showToday;

  @override
  bool operator ==(Object other) =>
      other is AppLinkTarget &&
      other.location == location &&
      other.anchor == anchor &&
      other.showToday == showToday;

  @override
  int get hashCode => Object.hash(location, anchor, showToday);

  @override
  String toString() =>
      'AppLinkTarget($location, anchor: $anchor, showToday: $showToday)';
}

/// Pure: maps a link from a widget, tile, shortcut, or App Intent to a
/// router target. The link name is the host (`cleartray://today`); a bare
/// path (`cleartray:today`) is accepted too. Unknown links open the Inbox.
AppLinkTarget resolveAppLink(Uri uri) {
  final name = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');
  switch (name) {
    case 'capture':
      return const AppLinkTarget('/capture');
    case 'today':
      return const AppLinkTarget('/do', showToday: true);
    case 'plan':
      return const AppLinkTarget('/today/plan', anchor: '/do', showToday: true);
    case 'process':
      return const AppLinkTarget('/process');
    case 'item':
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty) {
        return AppLinkTarget(
          '/item/${Uri.encodeComponent(id)}',
          anchor: '/do',
          showToday: true,
        );
      }
  }
  return const AppLinkTarget('/inbox');
}

/// Opens [uri] through the shared deep-link funnel.
void openAppLink(ProviderContainer container, Uri uri) {
  final target = resolveAppLink(uri);
  if (target.showToday) {
    unawaited(container.read(doViewProvider.notifier).set(DoView.today));
  }
  openDeepLink(
    container.read(routerProvider),
    target.location,
    anchor: target.anchor,
  );
}
