import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../app/router.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/adaptive_workspace.dart';

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
  const AppShell({
    required this.child,
    required this.location,
    this.detailBodyWidth,
    this.onNavigate,
    super.key,
  });

  final Widget child;
  final String location;

  /// A root detail route only adds navigation when its workspace still fits.
  /// In compact windows the route retains its existing Back affordance.
  final double? detailBodyWidth;
  final ValueChanged<String>? onNavigate;

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
    void select(int i) {
      final target = navTabs[i].path;
      if (target == location) return;
      final navigate = onNavigate;
      if (navigate == null) {
        context.go(target);
      } else {
        navigate(target);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const baseRailWidth = 80.0;
        const labelPadding = 8.0;
        final railWidth =
            baseRailWidth *
            math.max(1.0, MediaQuery.textScalerOf(context).scale(14) / 14);
        final rail = hasNavigationRailRoom(
          context,
          constraints,
          railWidth: baseRailWidth,
          detailWidth: detailBodyWidth ?? 560,
        );
        final keyboard = MediaQuery.viewInsetsOf(context).bottom;
        final body = SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: rail ? railWidth : 0,
                ),
                child: child,
              ),
              // Paint after the nested Navigator so its route semantics
              // cannot hide the shell destinations from accessibility.
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: rail ? math.min(keyboard, constraints.maxHeight) : 0,
                width: railWidth,
                child: Offstage(
                  offstage: !rail,
                  child: ExcludeFocus(
                    excluding: !rail,
                    child: SafeArea(
                      child: NavigationRail(
                        minWidth: railWidth,
                        labelType: NavigationRailLabelType.all,
                        scrollable: true,
                        selectedIndex: _index,
                        onDestinationSelected: select,
                        destinations: [
                          for (var i = 0; i < navTabs.length; i++)
                            NavigationRailDestination(
                              padding: const EdgeInsets.symmetric(
                                horizontal: labelPadding,
                              ),
                              icon: _IconWithBadge(
                                icon: navTabs[i].icon,
                                badge: i == 0 && inboxCount > 0
                                    ? inboxCount
                                    : null,
                              ),
                              selectedIcon: _IconWithBadge(
                                icon: navTabs[i].filled,
                                badge: i == 0 && inboxCount > 0
                                    ? inboxCount
                                    : null,
                              ),
                              label: SizedBox(
                                width: railWidth - 2 * labelPadding,
                                child: Text(
                                  _navTabLabel(l, navTabs[i].labelKey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        if (detailBodyWidth != null) {
          // Let the detail Scaffold handle keyboard insets and snack bars.
          return Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: body,
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset: !rail,
          body: body,
          bottomNavigationBar: rail
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: select,
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
      },
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
    return Badge.count(count: badge!, child: iconWidget);
  }
}
