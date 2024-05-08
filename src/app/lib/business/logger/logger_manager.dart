import 'dart:io';

import 'package:app/access/logger/logger_repository.dart';
import 'package:app/access/logger/custom_console_output.dart';
import 'package:app/access/logger/custom_file_output.dart';
import 'package:app/business/logger/level_log_filter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service that manages everything related to logging.
abstract interface class LoggerManager {
  factory LoggerManager(LoggerRepository loggerRepository) = _LoggerManager;

  /// Gets whether console logging is enabled.
  bool get isConsoleLoggingEnabled;

  /// Gets whether file logging is enabled.
  bool get isFileLoggingEnabled;

  /// Gets whether logging configuration been changed via either [setIsConsoleLoggingEnabled] or [setIsFileLoggingEnabled].
  bool get hasConfigurationBeenChanged;

  /// Create an instancee of [Logger].
  Future<Logger> createLogInstance();

  /// Deletes log file
  /// The [bool] returned indicates whether the log file has been deleted successfully.
  Future<bool> deleteLogFile();

  /// Shares log file via email.
  /// The [bool] returned indicates whether the file has been shared successfully (Dismissed by the user also counts as a success).
  Future<bool> shareLogFile();

  /// Sets whether console logging should be enabled on next app launch.
  Future setIsConsoleLoggingEnabled(bool isConsoleLoggingEnabled);

  /// Sets whether file logging should be enabled on next app launch.
  Future setIsFileLoggingEnabled(bool isFileLoggingEnabled);
}

/// Implementation of [LoggerManager].
final class _LoggerManager implements LoggerManager {
  final LoggerRepository _loggerRepository;

  late Logger _logger;

  File? _logFile;

  final String _fileName = "ApplicationTemplate.log";

  late bool _initialIsConsoleLoggingEnabled;
  late bool _initialIsFileLoggingEnabled;

  @override
  late bool isConsoleLoggingEnabled;

  @override
  late bool isFileLoggingEnabled;

  @override
  bool hasConfigurationBeenChanged = false;

  _LoggerManager(this._loggerRepository);

  @override
  Future<Logger> createLogInstance() async {
    final List<LogOutput> loggerOutputs = [];

    final loggingConfiguration =
        await _loggerRepository.getLoggingConfiguration();

    _initialIsConsoleLoggingEnabled =
        loggingConfiguration.isConsoleLoggingEnabled ??
            bool.parse(dotenv.env["IS_CONSOLE_LOGGING_ENABLED"] ?? 'false');
    if (_initialIsConsoleLoggingEnabled) {
      loggerOutputs.add(CustomConsoleOutput());
    }
    isConsoleLoggingEnabled = _initialIsConsoleLoggingEnabled;

    _initialIsFileLoggingEnabled = loggingConfiguration.isFileLoggingEnabled ??
        bool.parse(dotenv.env["IS_FILE_LOGGING_ENABLED"] ?? 'false');
    if (_initialIsFileLoggingEnabled) {
      // Initialize the log file.
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      _logFile = File('${appDocumentsDir.path}/$_fileName');
      loggerOutputs.add(CustomFileOutput(file: _logFile!));
    }
    isFileLoggingEnabled = _initialIsFileLoggingEnabled;

    var minimumLevel = dotenv.env['MINIMUM_LEVEL']!.toLogLevel();
    return _logger = Logger(
      filter: LevelLogFilter(minimumLevel),
      printer: PrefixPrinter(
        PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 9,
          stackTraceBeginIndex: 1,
          printTime: true,
          printEmojis: false,
          noBoxingByDefault: true,
        ),
      ),
      output: MultiOutput(loggerOutputs),
    );
  }

  @override
  Future<bool> deleteLogFile() async {
    _logger.d("Start deleting the log file.");
    if (_logFile != null && await _logFile!.exists()) {
      try {
        _logger.t("Log file exists. It's time to delete it.");

        await _logFile!.delete();

        _logger.i("The log file was deleted successfully.");
        return true;
      } catch (e, stackTrace) {
        _logger.e(
          'Failed to delete the log file.',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _logger.w('No log file to delete.');
    return false;
  }

  @override
  Future<bool> shareLogFile() async {
    _logger.d("Start sharing the log file.");
    if (_logFile != null &&
        (await _logFile!.exists()) &&
        (await _logFile!.length()) > 0) {
      try {
        _logger.t("Log file exists. It's time to share it.");

        var result = await Share.shareXFiles(
          [XFile(_logFile!.path)],
          subject: "Diagnostics - ApplicationTemplate ${DateTime.now()}",
        );

        _logger.i(
            "Share execution has been successful. It returned the following status ${result.status}.");

        return result.status != ShareResultStatus.unavailable;
      } catch (e, stackTrace) {
        _logger.e(
          'Failed to share log file.',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _logger.w("There's no log file to share.");
    return false;
  }

  @override
  Future setIsConsoleLoggingEnabled(bool isConsoleLoggingEnabled) async {
    await _loggerRepository.setIsConsoleLoggingEnabled(isConsoleLoggingEnabled);

    this.isConsoleLoggingEnabled = isConsoleLoggingEnabled;
    hasConfigurationBeenChanged = _checkIfChangesHasBeenMade();
  }

  @override
  Future setIsFileLoggingEnabled(bool isFileLoggingEnabled) async {
    await _loggerRepository.setIsFileLoggingEnabled(isFileLoggingEnabled);

    this.isFileLoggingEnabled = isFileLoggingEnabled;
    hasConfigurationBeenChanged = _checkIfChangesHasBeenMade();
  }

  bool _checkIfChangesHasBeenMade() =>
      isConsoleLoggingEnabled != _initialIsConsoleLoggingEnabled ||
      isFileLoggingEnabled != _initialIsFileLoggingEnabled;
}

extension StringToLogLevel on String {
  Level toLogLevel() {
    switch (this) {
      case 'all':
        return Level.all;
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
        return Level.fatal;
      case 'off':
        return Level.off;
      default:
        return Level.debug;
    }
  }
}
