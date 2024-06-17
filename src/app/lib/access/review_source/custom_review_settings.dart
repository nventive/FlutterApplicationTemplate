import 'package:review_service/src/review_service/review_settings.dart';

class CustomReviewSettings extends ReviewSettings {
  final int favoriteJokesCount;

  const CustomReviewSettings({
    this.favoriteJokesCount = 0,
    super.primaryActionCompletedCount = 0,
    super.secondaryActionCompletedCount = 0,
    super.applicationLaunchCount = 0,
    super.firstApplicationLaunch,
    super.requestCount = 0,
    super.lastRequest,
  });

  @override
  CustomReviewSettings copyWith({
    int? primaryActionCompletedCount,
    int? secondaryActionCompletedCount,
    int? applicationLaunchCount,
    DateTime? firstApplicationLaunch,
    int? requestCount,
    DateTime? lastRequest,
  }) {
    return CustomReviewSettings(
      primaryActionCompletedCount:
          primaryActionCompletedCount ?? this.primaryActionCompletedCount,
      secondaryActionCompletedCount:
          secondaryActionCompletedCount ?? this.secondaryActionCompletedCount,
      applicationLaunchCount:
          applicationLaunchCount ?? this.applicationLaunchCount,
      firstApplicationLaunch:
          firstApplicationLaunch ?? this.firstApplicationLaunch,
      requestCount: requestCount ?? this.requestCount,
      lastRequest: lastRequest ?? this.lastRequest,
      favoriteJokesCount: favoriteJokesCount,
    );
  }

  CustomReviewSettings copyWithFavorite(int favoriteCount) {
    return CustomReviewSettings(
      primaryActionCompletedCount: super.primaryActionCompletedCount,
      secondaryActionCompletedCount: super.secondaryActionCompletedCount,
      applicationLaunchCount: super.applicationLaunchCount,
      firstApplicationLaunch: super.firstApplicationLaunch,
      requestCount: super.requestCount,
      lastRequest: super.lastRequest,
      favoriteJokesCount: favoriteCount,
    );
  }
}
