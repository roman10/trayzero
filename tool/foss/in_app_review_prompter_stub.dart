// FOSS build stub — DO NOT EDIT FOR STORE BUILDS.
//
// `tool/foss/strip.sh` copies this file over
// `lib/infrastructure/in_app_review_prompter.dart` and drops the
// `in_app_review` dependency (its Android side bundles Google Play Core,
// which F-Droid rejects). It keeps the real adapter's public surface so
// `infrastructure/providers.dart` compiles unchanged.

import '../core/app_review.dart';

/// FOSS build: there is no store review sheet, so the prompt never shows.
class InAppReviewPrompter extends AppReviewPrompter {
  const InAppReviewPrompter();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> requestReview() async {}
}
