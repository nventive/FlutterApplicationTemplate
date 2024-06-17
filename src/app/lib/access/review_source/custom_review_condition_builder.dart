import 'package:app/access/review_source/custom_review_settings.dart';
import 'package:review_service/src/review_service/review_condition_builder.dart';
import 'package:review_service/src/review_service/synchronous_review_condition.dart';

extension CustomReviewConditionsBuilderExtensions
    on ReviewConditionsBuilder<CustomReviewSettings> {
  ReviewConditionsBuilder<CustomReviewSettings> minimumJokesFavorited(
    int minimumJokesFavorited,
  ) {
    conditions.add(
      SynchronousReviewCondition<CustomReviewSettings>(
        (reviewSettings, currentDateTime) =>
            reviewSettings.favoriteJokesCount >= minimumJokesFavorited,
      ),
    );
    return this;
  }
}
