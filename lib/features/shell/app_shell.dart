import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../app/router.dart';
import '../../l10n/gen/app_localizations.dart';

String _navTabLabel(AppLocalizations l, NavTabKey key) {
  switch (key) {
    case NavTabKey.inbox:
      return l.navInbox;
    case NavTabKey.doIt:
      return l.navDo;
    case NavTabKey.projects:
      return l.navProjects;
    case NavTabKey.review:
      return l.navReview;
    case NavTabKey.more:
      return l.navMore;
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  int get _index {
    for (var i = 0; i < navTabs.length; i++) {
      if (location.startsWith(navTabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxCount = ref.watch(inboxCountProvider).valueOrNull ?? 0;
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(top: false, bottom: false, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          final target = navTabs[i].path;
          if (target == location) return;
          context.go(target);
        },
        destinations: [
          for (var i = 0; i < navTabs.length; i++)
            NavigationDestination(
              icon: _IconWithBadge(
                icon: navTabs[i].icon,
                badge: i == 0 && inboxCount > 0 ? inboxCount : null,
              ),
              selectedIcon: _IconWithBadge(
                icon: navTabs[i].filled,
                badge: i == 0 && inboxCount > 0 ? inboxCount : null,
              ),
              label: _navTabLabel(l, navTabs[i].labelKey),
              tooltip: _navTabLabel(l, navTabs[i].labelKey),
            ),
        ],
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({required this.icon, this.badge});
  final IconData icon;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon);
    if (badge == null || badge == 0) return iconWidget;
    return Badge.count(
      count: badge!,
      child: iconWidget,
    );
  }
}
