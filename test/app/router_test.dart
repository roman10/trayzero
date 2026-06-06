import 'package:cleartray/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pure deep-link policy. A notification tap or a home-screen widget
/// navigates via `.go()`, which *replaces* the navigation stack. A detail
/// route opened that way has nothing behind it, so when it pops itself
/// (mark-complete, delete, the capture sheet closing, the back gesture) the
/// navigator is left empty — a black screen. [deepLinkPlan] anchors the
/// Inbox tab beneath every non-shell route so the pop always has a home.
void main() {
  group('isShellLocation', () {
    test('the five bottom-nav tabs are self-contained', () {
      for (final p in ['/inbox', '/do', '/projects', '/review', '/settings']) {
        expect(isShellLocation(p), isTrue, reason: p);
      }
    });

    test('detail routes are not shell tabs', () {
      for (final p in [
        '/item/abc',
        '/capture',
        '/process',
        '/project/p1',
        '/settings/contexts',
        '/settings/areas',
        '/settings/calendar-sync',
      ]) {
        expect(isShellLocation(p), isFalse, reason: p);
      }
    });

    test('a query string does not change the answer', () {
      expect(isShellLocation('/inbox?from=widget'), isTrue);
      expect(isShellLocation('/capture?text=hi%20there'), isFalse);
    });
  });

  group('deepLinkPlan', () {
    test('a shell tab is opened directly, with no anchor', () {
      expect(deepLinkPlan('/inbox'), [const DeepLinkStep.go('/inbox')]);
      expect(deepLinkPlan('/review'), [const DeepLinkStep.go('/review')]);
      expect(deepLinkPlan('/settings'), [const DeepLinkStep.go('/settings')]);
    });

    test('an item detail route is pushed onto the Inbox tab', () {
      expect(deepLinkPlan('/item/abc'), const [
        DeepLinkStep.go('/inbox'),
        DeepLinkStep.push('/item/abc'),
      ]);
    });

    test('the capture route is pushed onto the Inbox tab', () {
      expect(deepLinkPlan('/capture'), const [
        DeepLinkStep.go('/inbox'),
        DeepLinkStep.push('/capture'),
      ]);
    });

    test('other non-shell routes are anchored too', () {
      for (final p in ['/process', '/project/p1', '/settings/contexts']) {
        expect(
          deepLinkPlan(p),
          [const DeepLinkStep.go('/inbox'), DeepLinkStep.push(p)],
          reason: p,
        );
      }
    });

    test('the full location, including its query, is preserved on push', () {
      expect(deepLinkPlan('/capture?text=hi%20there'), const [
        DeepLinkStep.go('/inbox'),
        DeepLinkStep.push('/capture?text=hi%20there'),
      ]);
    });
  });
}
