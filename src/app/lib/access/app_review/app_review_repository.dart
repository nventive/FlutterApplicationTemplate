import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppReviewRepository {
  factory AppReviewRepository() = _AppReviewRepository;

  Future<DateTime?> getLastPromptDate();
  Future<void> setLastPromptDate(DateTime date);
}

final class _AppReviewRepository implements AppReviewRepository {
  static const String _lastPromptDateKey = 'last_prompt_date';

  @override
  Future<DateTime?> getLastPromptDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastPromptDateKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  @override
  Future<void> setLastPromptDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPromptDateKey, date.millisecondsSinceEpoch);
  }
}
