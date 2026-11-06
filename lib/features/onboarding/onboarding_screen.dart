import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../data/seed.dart';
import '../../l10n/gen/app_localizations.dart';
import '../common/readable_page_body.dart';
import '../settings/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _seedSample = true;
  // Replaying onboarding from About: the user already has projects, so
  // default the sample off instead of duplicating it on every replay.
  int _existingProjects = 0;

  static const _pageIcons = <IconData>[
    Icons.psychology_alt_outlined,
    Icons.bolt,
    Icons.play_arrow_outlined,
    Icons.refresh,
  ];

  List<_OnboardPage> _pagesFor(AppLocalizations l) => <_OnboardPage>[
    _OnboardPage(
      icon: _pageIcons[0],
      title: l.onboardingPage1Title,
      body: l.onboardingPage1Body,
    ),
    _OnboardPage(
      icon: _pageIcons[1],
      title: l.onboardingPage2Title,
      body: l.onboardingPage2Body,
    ),
    _OnboardPage(
      icon: _pageIcons[2],
      title: l.onboardingPage3Title,
      body: l.onboardingPage3Body,
    ),
    _OnboardPage(
      icon: _pageIcons[3],
      title: l.onboardingPage4Title,
      body: l.onboardingPage4Body,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProjects();
  }

  Future<void> _loadExistingProjects() async {
    try {
      final projects =
          await ref.read(projectRepositoryProvider).watchAll().first;
      if (!mounted || projects.isEmpty) return;
      setState(() {
        _existingProjects = projects.length;
        _seedSample = false;
      });
    } catch (_) {
      // Best effort: keep the first-run default.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// [seed] is false for Skip, which never creates sample data.
  Future<void> _finish({required bool seed}) async {
    if (seed) {
      final l10n = AppLocalizations.of(context);
      await seedSampleProject(
        projects: ref.read(projectRepositoryProvider),
        items: ref.read(itemRepositoryProvider),
        contexts: ref.read(contextRepositoryProvider),
        ids: ref.read(idGeneratorProvider),
        clock: ref.read(clockProvider),
        computerLabel: l10n.seedContextComputer,
        projectTitle: l10n.sampleProjectTitle,
        projectOutcome: l10n.sampleProjectOutcome,
        readPrimerTitle: l10n.sampleItemReadPrimer,
        emptyEmailTitle: l10n.sampleItemEmptyEmail,
        scheduleReviewTitle: l10n.sampleItemScheduleReview,
      );
    }
    await ref.read(onboardingCompleteProvider.notifier).complete();
    if (!mounted) return;
    context.go('/inbox');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final pages = _pagesFor(l);
    final isLast = _page == pages.length;
    return Scaffold(
      body: ReadablePageBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l.appName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isLast)
                    Flexible(
                      child: TextButton(
                        onPressed: () => _finish(seed: false),
                        child: Text(l.skip),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (var i = 0; i < pages.length; i++)
                    _PageView(
                      page: pages[i],
                      // Inside the scrollable page so large text never pushes
                      // the Next button off a small screen.
                      footer: i == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: TextButton(
                                key: const ValueKey('onboarding_restore'),
                                onPressed: () => context.push(
                                  '/settings/backup/restore?onboarding=1',
                                ),
                                child: Text(l.onboardingRestoreAction),
                              ),
                            )
                          : null,
                    ),
                  _SeedView(
                    seedSample: _seedSample,
                    existingProjects: _existingProjects,
                    onChange: (v) => setState(() => _seedSample = v),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length + 1; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? scheme.primary
                          : scheme.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _page == pages.length
                        ? FilledButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(l.onboardingFinish),
                            onPressed: () => _finish(seed: _seedSample),
                          )
                        : FilledButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(l.next),
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page, this.footer});
  final _OnboardPage page;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ScrollablePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(page.icon, size: 36, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 28),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.body,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}

class _SeedView extends StatelessWidget {
  const _SeedView({
    required this.seedSample,
    required this.existingProjects,
    required this.onChange,
  });
  final bool seedSample;
  final int existingProjects;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return _ScrollablePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.checklist,
              size: 36,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l.onboardingSeedTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l.onboardingSeedBody,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: seedSample,
            onChanged: onChange,
            title: Text(l.onboardingSeedSampleLabel),
            subtitle: Text(
              existingProjects > 0
                  ? l.onboardingSeedExisting(existingProjects)
                  : l.onboardingSeedSampleSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Centers short pages and makes every paragraph/control reachable when
/// accessibility text or a compact display needs more room than the viewport.
class _ScrollablePage extends StatelessWidget {
  const _ScrollablePage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: child,
        ),
      ),
    ),
  );
}
