import 'package:cleartray/app/app_links.dart';
import 'package:cleartray/app/router.dart';
import 'package:flutter_test/flutter_test.dart';

/// Links from widgets, the tile, launcher shortcuts, and App Intents
/// (ADR 0009).
void main() {
  AppLinkTarget resolve(String link) => resolveAppLink(Uri.parse(link));

  test('capture and process anchor the Inbox', () {
    expect(resolve('cleartray://capture'), const AppLinkTarget('/capture'));
    expect(resolve('cleartray://process'), const AppLinkTarget('/process'));
    expect(resolve('cleartray://inbox'), const AppLinkTarget('/inbox'));
  });

  test('today, plan, and items open on the Today view', () {
    expect(
      resolve('cleartray://today'),
      const AppLinkTarget('/do', showToday: true),
    );
    expect(
      resolve('cleartray://plan'),
      const AppLinkTarget('/today/plan', anchor: '/do', showToday: true),
    );
    expect(
      resolve('cleartray://item?id=abc-1'),
      const AppLinkTarget('/item/abc-1', anchor: '/do', showToday: true),
    );
  });

  test('a bare path form is accepted', () {
    expect(resolve('cleartray:capture'), const AppLinkTarget('/capture'));
  });

  test('unknown links and items without an id open the Inbox', () {
    expect(resolve('cleartray://nope'), const AppLinkTarget('/inbox'));
    expect(resolve('cleartray://item'), const AppLinkTarget('/inbox'));
    expect(resolve('cleartray://item?id='), const AppLinkTarget('/inbox'));
  });

  test('item ids are encoded into one path segment', () {
    expect(resolve('cleartray://item?id=a%2Fb').location, '/item/a%2Fb');
  });

  test('detail links anchor the requested tab beneath them', () {
    expect(deepLinkPlan('/today/plan', anchor: '/do'), const [
      DeepLinkStep.go('/do'),
      DeepLinkStep.push('/today/plan'),
    ]);
    expect(deepLinkPlan('/do', anchor: '/do'), const [DeepLinkStep.go('/do')]);
  });
}
