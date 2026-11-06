import 'package:in_app_review/in_app_review.dart';

import '../core/app_review.dart';

/// Store builds: the platform in-app review sheet (Play In-App Review /
/// SKStoreReviewController). The FOSS transform replaces this file with
/// `tool/foss/in_app_review_prompter_stub.dart` and drops the dependency,
/// because the Android plugin bundles Google Play Core.
class InAppReviewPrompter extends AppReviewPrompter {
  const InAppReviewPrompter();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();
}
