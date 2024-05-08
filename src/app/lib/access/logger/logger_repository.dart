import 'package:app/access/logger/logging_configuration_data.dart';
import 'package:app/access/persistence_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contract repository to handle logging configuration.
abstract interface class LoggerRepository {
  factory LoggerRepository() = _LoggerRepository;

  /// Loads the current logging configuration.
  Future<LoggingConfigurationData> getLoggingConfiguration();

  /// Sets whether console logging should be enabled on next app launch.
  Future setIsConsoleLoggingEnabled(bool isConsoleLoggingEnabled);

  /// Sets whether file logging should be enabled on next app launch.
  Future setIsFileLoggingEnabled(bool isFileLoggingEnabled);
}

/// Implementation of [LoggerRepository].
final class _LoggerRepository implements LoggerRepository {
  /// The key used to store the selected environment in shared preferences.
  final String _consoleLoggingKey = 'consoleLogging';
  final String _fileloggingKey = 'fileLogging';

  @override
  Future<LoggingConfigurationData> getLoggingConfiguration() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return LoggingConfigurationData(
      isConsoleLoggingEnabled: sharedPreferences.getBool(_consoleLoggingKey),
      isFileLoggingEnabled: sharedPreferences.getBool(_fileloggingKey),
    );
  }

  @override
  Future setIsConsoleLoggingEnabled(bool isConsoleLoggingEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var isSaved = await sharedPreferences.setBool(
      _consoleLoggingKey,
      isConsoleLoggingEnabled,
    );

    if (!isSaved) {
      throw const PersistenceException();
    }
  }

  @override
  Future setIsFileLoggingEnabled(bool isFileLoggingEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var isSaved = await sharedPreferences.setBool(
      _fileloggingKey,
      isFileLoggingEnabled,
    );

    if (!isSaved) {
      throw const PersistenceException();
    }
  }
}
