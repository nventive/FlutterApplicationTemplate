/// Entity that represents the current state of the logging configuration persisted.
final class LoggingConfigurationData {
  /// Gets whether console logging is enabled. If [Null], it fallbacks to the value set from the current environment.
  final bool? isConsoleLoggingEnabled;

  /// Gets whether file logging is enabled. If [Null], it fallbacks to the value set from the current environment.
  final bool? isFileLoggingEnabled;

  const LoggingConfigurationData({
    required this.isConsoleLoggingEnabled,
    required this.isFileLoggingEnabled,
  });
}
