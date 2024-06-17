import 'package:app/access/review_source/custom_review_settings.dart';
import 'package:review_service/src/review_service/review_service.dart';

/// This interface wraps ReviewService<CustomReviewSettings> so that you don't have to repeat the generic parameter everywhere that you would use the review service.
/// In other words, you should use this interface in the app instead of ReviewService<CustomReviewSettings> because it's leaner.
class CustomReviewService implements ReviewService<CustomReviewSettings> {
  late ReviewService<CustomReviewSettings> _reviewService;

  CustomReviewService(ReviewService<CustomReviewSettings> reviewService) {
    _reviewService = reviewService;
  }

  @override
  Future<bool> getAreConditionsSatisfied() async {
    return await _reviewService.getAreConditionsSatisfied();
  }

  @override
  Future<void> tryRequestReview() async {
    await _reviewService.tryRequestReview();
  }

  @override
  Future<void> updateReviewSettings(
    CustomReviewSettings Function(CustomReviewSettings p1) updateFunction,
  ) async {
    await _reviewService.updateReviewSettings(updateFunction);
  }
}
