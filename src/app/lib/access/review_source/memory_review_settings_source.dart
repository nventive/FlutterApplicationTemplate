import 'package:app/access/review_source/custom_review_settings.dart';
import 'package:review_service/src/review_service/review_settings_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomMemoryReviewSettingsSource
    implements ReviewSettingsSource<CustomReviewSettings> {
  final String _reviewSettingsKey = 'reviewSettings';

  @override
  Future<CustomReviewSettings> read() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final reviewSettingsString =
        sharedPreferences.getString(_reviewSettingsKey) ?? '0';

    return CustomReviewSettings(
      favoriteJokesCount: int.parse(reviewSettingsString),
    );
  }

  @override
  Future<void> write(CustomReviewSettings reviewSettings) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      _reviewSettingsKey,
      reviewSettings.favoriteJokesCount.toString(),
    );
  }
}
