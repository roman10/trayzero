import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers.dart';
import '../../core/clock.dart';
import '../../core/id_generator.dart';
import '../../data/seed.dart';
import '../../l10n/gen/app_localizations.dart';
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_seedSample) {
      await seedSampleProject(
        projects: ref.read(projectRepositoryProvider),
        items: ref.read(itemRepositoryProvider),
        contexts: ref.read(contextRepositoryProvider),
        ids: ref.read(idGeneratorProvider),
        clock: ref.read(clockProvider),
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
    final isLast = _page == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    l.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: Text(l.skip),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final p in pages) _PageView(page: p),
                  _SeedView(
                    seedSample: _seedSample,
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
                            onPressed: _finish,
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
  const _PageView({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
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
        ],
      ),
    );
  }
}

class _SeedView extends StatelessWidget {
  const _SeedView({required this.seedSample, required this.onChange});
  final bool seedSample;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
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
            child:
                Icon(Icons.checklist, size: 36, color: scheme.onPrimaryContainer),
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
            subtitle: Text(l.onboardingSeedSampleSubtitle),
          ),
        ],
      ),
    );
  }
}
