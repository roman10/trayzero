import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/import/import_plan.dart';
import '../features/app_import/app_import_screen.dart';
import '../features/app_import/app_import_source_screen.dart';
import '../features/areas/areas_screen.dart';
import '../features/calendar_sync/calendar_sync_screen.dart';
import '../features/capture/capture_sheet.dart';
import '../features/contexts/contexts_screen.dart';
import '../features/engage/daily_plan_screen.dart';
import '../features/engage/engage_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/item_edit/item_edit_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/process/process_inbox_screen.dart';
import '../features/projects/organize_actions_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/review/review_screen.dart';
import '../features/review/weekly_review_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/appearance_screen.dart';
import '../features/settings/backup_screen.dart';
import '../features/settings/restore_from_folder_screen.dart';
import '../features/settings/reminders_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/support_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/tags/agenda_screen.dart';
import '../features/tags/tags_screen.dart';
import 'item_workspace.dart';
import 'project_item_workspace.dart';
import 'project_workspace.dart';
import 'weekly_review_item_workspace.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: onboardingComplete ? '/inbox' : '/onboarding',
    routes: [
      GoRoute(
        path: '/review/weekly',
        name: 'weekly-review',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const WeeklyReviewScreen(),
      ),
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
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          if (state.uri.queryParameters['review'] == 'weekly') {
            return WeeklyReviewItemWorkspace(itemId: id);
          }
          final projectId = state.uri.queryParameters['project'];
          if (projectId != null && projectId.isNotEmpty) {
            return ProjectItemWorkspace(itemId: id, projectId: projectId);
          }
          final source = state.uri.queryParameters['workspace'];
          if (source == 'inbox' || source == 'do' || source == 'search') {
            final offset = state.extra is double ? state.extra as double : 0.0;
            return ItemWorkspace(
              itemId: id,
              queryParameters: {'workspace': source!},
              routeExtra: state.extra,
              minPrimaryWidth: source == 'inbox' ? 240 : 320,
              navigationLocation: source == 'search' ? null : '/$source',
              primaryBuilder: (select) => switch (source) {
                'inbox' => InboxScreen(
                  onOpenItem: select,
                  selectedItemId: id,
                  initialScrollOffset: offset,
                ),
                'do' => EngageScreen(
                  onOpenItem: select,
                  selectedItemId: id,
                  initialScrollOffset: offset,
                ),
                _ => SearchScreen(
                  onOpenItem: select,
                  selectedItemId: id,
                  initialScrollOffset: offset,
                ),
              },
            );
          }
          return ItemEditScreen(key: ValueKey(id), itemId: id);
        },
      ),
      GoRoute(
        path: '/process',
        name: 'process',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProcessInboxScreen(),
      ),
      GoRoute(
        path: '/today/plan',
        name: 'daily-plan',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const DailyPlanScreen(),
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
        builder: (_, state) => ProjectWorkspace(
          projectId: state.pathParameters['id']!,
          initialScrollOffset: state.extra is double ? state.extra as double : 0,
        ),
      ),
      GoRoute(
        path: '/settings/contexts',
        name: 'contexts',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ContextsScreen(),
      ),
      GoRoute(
        path: '/settings/tags',
        name: 'tags',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const TagsScreen(),
      ),
      GoRoute(
        path: '/agenda/:id',
        name: 'agenda',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            AgendaScreen(tagId: state.pathParameters['id']!),
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
      GoRoute(
        path: '/settings/import',
        name: 'app-import',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AppImportScreen(),
      ),
      GoRoute(
        path: '/settings/import/:source',
        name: 'app-import-source',
        parentNavigatorKey: _rootKey,
        redirect: (_, state) =>
            ImportSourceApp.values.asNameMap()[state.pathParameters['source']] ==
                null
            ? '/settings/import'
            : null,
        builder: (_, state) => AppImportSourceScreen(
          source: ImportSourceApp.values.byName(
            state.pathParameters['source']!,
          ),
        ),
      ),
      GoRoute(
        path: '/settings/appearance',
        name: 'appearance',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/settings/reminders',
        name: 'reminders',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        name: 'backup',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BackupScreen(),
      ),
      GoRoute(
        path: '/settings/backup/restore',
        name: 'backup-restore',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => RestoreFromFolderScreen(
          fromOnboarding: state.uri.queryParameters['onboarding'] == '1',
        ),
      ),
      GoRoute(
        path: '/settings/support',
        name: 'support',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SupportScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        name: 'about',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AboutScreen(),
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
/// that pop lands on an empty navigator: a black screen. Anchoring a tab
/// ([anchor], the Inbox by default) beneath it gives the pop somewhere to
/// return to.
List<DeepLinkStep> deepLinkPlan(String location, {String anchor = '/inbox'}) =>
    isShellLocation(location)
    ? [DeepLinkStep.go(location)]
    : [DeepLinkStep.go(anchor), DeepLinkStep.push(location)];

/// Executes [deepLinkPlan] for [location] on [router]. The single funnel
/// every notification / home-widget deep link goes through.
void openDeepLink(GoRouter router, String location, {String anchor = '/inbox'}) {
  for (final step in deepLinkPlan(location, anchor: anchor)) {
    switch (step.kind) {
      case DeepLinkNav.go:
        router.go(step.location);
      case DeepLinkNav.push:
        router.push(step.location);
    }
  }
}
