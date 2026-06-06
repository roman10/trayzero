import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/areas/areas_screen.dart';
import '../features/calendar_sync/calendar_sync_screen.dart';
import '../features/capture/capture_sheet.dart';
import '../features/contexts/contexts_screen.dart';
import '../features/engage/engage_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/item_edit/item_edit_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/process/process_inbox_screen.dart';
import '../features/projects/organize_actions_screen.dart';
import '../features/projects/project_detail_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/review/review_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboardingComplete ? '/inbox' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/capture',
        name: 'capture',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: CaptureScreen(
            initialText: state.uri.queryParameters['text'],
          ),
        ),
      ),
      GoRoute(
        path: '/item/:id',
        name: 'item',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ItemEditScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/process',
        name: 'process',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProcessInboxScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/organize',
        name: 'organize',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const OrganizeActionsScreen(),
      ),
      GoRoute(
        path: '/project/:id',
        name: 'project',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings/contexts',
        name: 'contexts',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ContextsScreen(),
      ),
      GoRoute(
        path: '/settings/areas',
        name: 'areas',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AreasScreen(),
      ),
      GoRoute(
        path: '/settings/calendar-sync',
        name: 'calendar-sync',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const CalendarSyncScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/inbox',
            name: 'inbox',
            pageBuilder: (_, _) =>
                _noTransitionPage(const InboxScreen()),
          ),
          GoRoute(
            path: '/do',
            name: 'do',
            pageBuilder: (_, _) =>
                _noTransitionPage(const EngageScreen()),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            pageBuilder: (_, _) =>
                _noTransitionPage(const ProjectsScreen()),
          ),
          GoRoute(
            path: '/review',
            name: 'review',
            pageBuilder: (_, _) =>
                _noTransitionPage(const ReviewScreen()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (_, _) =>
                _noTransitionPage(const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

CustomTransitionPage<void> _noTransitionPage(Widget child) =>
    CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (_, _, _, c) => c,
    );

/// Identifier for each bottom-nav tab. Used to look up its localized label
/// via [AppLocalizations] in the shell so the const [navTabs] table itself
/// stays free of locale-bound strings.
enum NavTabKey { inbox, doIt, projects, review, more }

/// Mapping of bottom-nav indices ↔ root paths. [labelKey] picks the
/// localized label at render time (see `app_shell.dart`).
const navTabs =
    <({String path, NavTabKey labelKey, IconData icon, IconData filled})>[
  (
    path: '/inbox',
    labelKey: NavTabKey.inbox,
    icon: Icons.inbox_outlined,
    filled: Icons.inbox,
  ),
  (
    path: '/do',
    labelKey: NavTabKey.doIt,
    icon: Icons.play_arrow_outlined,
    filled: Icons.play_arrow,
  ),
  (
    path: '/projects',
    labelKey: NavTabKey.projects,
    icon: Icons.folder_outlined,
    filled: Icons.folder,
  ),
  (
    path: '/review',
    labelKey: NavTabKey.review,
    icon: Icons.refresh_outlined,
    filled: Icons.refresh,
  ),
  (
    path: '/settings',
    labelKey: NavTabKey.more,
    icon: Icons.tune_outlined,
    filled: Icons.tune,
  ),
];

/// The self-contained shell tabs, derived from [navTabs] so the two can
/// never drift apart. Anything *not* in here is a detail route that lives
/// on top of a tab.
final _shellPaths = {for (final t in navTabs) t.path};

/// Whether [location] is one of the self-contained bottom-nav tabs (vs. a
/// detail route that sits on top of one). Compared by path, so a query
/// string (e.g. `/inbox?...`) does not change the answer.
bool isShellLocation(String location) =>
    _shellPaths.contains(Uri.parse(location).path);

enum DeepLinkNav { go, push }

/// One step of a deep-link navigation plan. Pure data so the policy is
/// unit-testable without a widget tree.
class DeepLinkStep {
  const DeepLinkStep.go(this.location) : kind = DeepLinkNav.go;
  const DeepLinkStep.push(this.location) : kind = DeepLinkNav.push;

  final DeepLinkNav kind;
  final String location;

  @override
  bool operator ==(Object other) =>
      other is DeepLinkStep &&
      other.kind == kind &&
      other.location == location;

  @override
  int get hashCode => Object.hash(kind, location);

  @override
  String toString() => 'DeepLinkStep.${kind.name}($location)';
}

/// How to open an external deep link so the destination always has a real
/// screen behind it.
///
/// A shell tab is self-contained, so we just switch to it. Every other
/// route is a detail screen that pops itself — mark-complete, delete, the
/// capture sheet closing, or the plain system back gesture. Opened bare via
/// `.go()` from a notification tap or a home-screen widget on a cold start,
/// that pop lands on an empty navigator: a black screen. Anchoring the
/// Inbox tab beneath it gives the pop somewhere to return to.
List<DeepLinkStep> deepLinkPlan(String location) => isShellLocation(location)
    ? [DeepLinkStep.go(location)]
    : [const DeepLinkStep.go('/inbox'), DeepLinkStep.push(location)];

/// Executes [deepLinkPlan] for [location] on [router]. The single funnel
/// every notification / home-widget deep link goes through.
void openDeepLink(GoRouter router, String location) {
  for (final step in deepLinkPlan(location)) {
    switch (step.kind) {
      case DeepLinkNav.go:
        router.go(step.location);
      case DeepLinkNav.push:
        router.push(step.location);
    }
  }
}
