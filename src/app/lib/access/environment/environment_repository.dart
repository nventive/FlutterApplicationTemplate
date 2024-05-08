import 'package:app/access/persistence_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract repository to handle environment selection.
abstract interface class EnvironmentRepository {
  factory EnvironmentRepository() = _EnvironmentRepository;

  /// Loads the current selected environment.
  Future<String?> getEnvironment();

  /// Sets the environment to apply on next app launch.
  Future setEnvironment(String environment);
}

/// Implementation of [EnvironmentRepository].
final class _EnvironmentRepository implements EnvironmentRepository {
  /// The key used to store the selected environment in shared preferences.
  final String _environmentKey = 'environment';

  @override
  Future setEnvironment(String environment) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var isSaved =
        await sharedPreferences.setString(_environmentKey, environment);

    if (!isSaved) {
      throw const PersistenceException();
    }
  }

  @override
  Future<String?> getEnvironment() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_environmentKey);
  }
}
