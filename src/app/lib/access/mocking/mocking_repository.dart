import 'package:shared_preferences/shared_preferences.dart';

/// Defines the repository for mocking data throughout the app.
abstract interface class MockingRepository {
  factory MockingRepository() = _MockingRepository;

  /// Gets whether the mocking is enabled.
  Future<bool> isMockingEnabled();

  /// Sets the mocking state.
  Future<void> setMocking(bool enabled);
}

/// Implementation of [MockingRepository].
final class _MockingRepository implements MockingRepository {
  /// The key used to store the mocking state in shared preferences.
  final String _mockingEnabledKey = 'mockingEnabled';
  
  @override
  Future<bool> isMockingEnabled() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_mockingEnabledKey) ?? false;
  }
  
  @override
  Future<void> setMocking(bool enabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_mockingEnabledKey, enabled);
  }
}