import 'package:shared_preferences/shared_preferences.dart';

abstract interface class MockingRepository {
  factory MockingRepository() = _MockingRepository;

  /// Gets whether the mocking is enabled.
  Future<bool> checkMockingEnabled();

  /// Sets the mocking state.
  Future setMocking(bool enabled);
}

/// Implementation of [MockingRepository].
final class _MockingRepository implements MockingRepository {
  /// The key used to store the mocking state in shared preferences.
  final String _mockingEnabledKey = 'mockingEnabled';
  
  @override
  Future<bool> checkMockingEnabled() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_mockingEnabledKey) ?? false;
  }
  
  @override
  Future setMocking(bool enabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(_mockingEnabledKey, enabled);
  }
}