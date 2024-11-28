import 'dart:async';
import 'dart:io';
import 'package:app/access/bugsee/bugsee_configuration_data.dart';
import 'package:app/access/bugsee/bugsee_repository.dart';
import 'package:app/access/persistence_exception.dart';
import 'package:app/business/bugsee/bugsee_config_state.dart';
import 'package:app/business/logger/logger_manager.dart';
import 'package:bugsee_flutter/bugsee_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:logger/web.dart';

const String bugseeTokenFormat =
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
const String bugseeFilterRegex = r'.';

/// Service related to initializing Bugsee service
abstract interface class BugseeManager {
  factory BugseeManager() = _BugseeManager;

  /// Current BugseeManager state
  BugseeConfigState get bugseeConfigState;

  /// Initialize bugsee with given token
  /// bugsee is not available in debug mode
  /// * [bugseeToken]: nullable bugsee token, if null bugsee won't be initialized make sure you provide
  /// [BUGSEE_TOKEN] in the env using `--dart-define` or `launch.json` on vscode
  Future<void> initialize({
    String? bugseeToken,
    bool isMock,
    required Logger logger,
    required LoggerManager loggerManager,
    required BugseeRepository bugseeRepository,
  });

  /// Manually log a provided exception with a stack trace
  /// (medium severity exception in Bugsee dashboard)
  ///
  ///* exception: the exception instance that will be reported
  ///* stackTrace: the strack trace of the exception, by default it's null
  ///* traces: the traces that led to the exception.
  ///* events: the events where the exception has been caught.
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
    Map<String, dynamic> traces,
    Map<String, Map<String, dynamic>?> events,
  });

  /// Manually update the current BugseeEnabled flag in shared prefs and in current manager singleton.
  Future<void> setIsBugseeEnabled(bool value);

  /// Manually update isDataObscured flag in shared prefs and in current state [bugseeConfigState].
  Future<void> setIsDataObscured(bool value);

  /// Manually update the current enableVideoCapture flag in shared prefs and in current manager singleton.
  Future<void> setIsVideoCaptureEnabled(bool value);

  /// Manually shows the built-in capture log report screen of Bugsee.
  Future<void> showCaptureLogReport();

  /// Manually update whether logs will be collected or not flag in shared prefs.
  Future<void> setIsLogsCollectionEnabled(bool value);

  /// Manually update isLogFilterEnabled flag in shared prefs.
  Future<void> setIsLogFilterEnabeld(bool value);

  /// Manually update whether Bugsee attach the log file with the reported
  /// exception or not.
  ///
  /// By default the log file is attached
  Future<void> setAttachLogFileEnabled(bool value);

  /// Intecept all unhandled exception thrown by the dart framework
  Future<void> inteceptExceptions(Object error, StackTrace stackTrace);

  /// Intercept all unhandled rending exception thrown by the Flutter framework
  Future<void> inteceptRenderExceptions(FlutterErrorDetails error);

  /// Manually add a map of attributes
  /// - the map entry key is the attribute name
  /// - the map entry value is the attribute value (string, int, boolean)
  ///
  /// Attributes will be attached to all reported exception unless app is uninstalled
  /// or attributes are removed manually
  Future<void> addAttributes(Map<String, dynamic> attributes);

  /// Manually add an email attached to all reported.
  ///
  /// The email will be attached to all reported exception unless app is uninstalled
  /// or the email is removed manually.
  Future<void> addEmailAttribute(String email);

  /// Manually remove the email attribute attached using [addEmailAttribute]
  Future<void> clearEmailAttribute();

  /// Manually remove an attribute by the given key attached using [addAttributes]
  Future<void> clearAttribute(String attribute);
}

final class _BugseeManager implements BugseeManager {
  late Logger logger;
  late LoggerManager loggerManager;
  late BugseeRepository bugseeRepository;

  _BugseeManager();

  BugseeConfigState _currentState = const BugseeConfigState();

  @override
  BugseeConfigState get bugseeConfigState => _currentState;

  late bool _isBugSeeInitialized;
  late BugseeConfigurationData configurationData;

  BugseeLaunchOptions? launchOptions;

  @override
  Future<void> initialize({
    String? bugseeToken,
    bool isMock = false,
    required Logger logger,
    required LoggerManager loggerManager,
    required BugseeRepository bugseeRepository,
  }) async {
    this.logger = logger;
    this.loggerManager = loggerManager;
    this.bugseeRepository = bugseeRepository;

    if (!Platform.isIOS && !Platform.isAndroid) {
      _currentState = _currentState.copyWith(
        isConfigurationValid: false,
        configErrorEnum: ConfigErrorEnum.invalidPlatform,
      );
      logger.i("BUGSEE: ${_currentState.configErrorEnum?.error}");
      return;
    }

    configurationData = await bugseeRepository.getBugseeConfiguration();
    configurationData = configurationData.copyWith(
      isLogCollectionEnabled: configurationData.isLogCollectionEnabled ??
          bool.parse(
            dotenv.env['BUGSEE_DISABLE_LOG_COLLECTION'] ?? 'true',
          ),
      isLogsFilterEnabled: configurationData.isLogsFilterEnabled ??
          bool.parse(
            dotenv.env['BUGSEE_FILTER_LOG_COLLECTION'] ?? 'true',
          ),
      isDataObscured: configurationData.isDataObscured ??
          bool.parse(dotenv.env['BUGSEE_IS_DATA_OBSCURE'] ?? 'true'),
      attachLogFileEnabled: configurationData.attachLogFileEnabled ??
          bool.parse(dotenv.env['BUGSEE_ATTACH_LOG_FILE'] ?? 'true'),
    );

    launchOptions = _initializeLaunchOptions();
    _isBugSeeInitialized = false;

    if (isMock) {
      _initializeBugsee(bugseeToken ?? '');
      return;
    }

    if (kDebugMode) {
      _currentState = _currentState.copyWith(
        isConfigurationValid: false,
        configErrorEnum: ConfigErrorEnum.invalidReleaseMode,
      );
      logger.i("BUGSEE: ${_currentState.configErrorEnum?.error}");
      return;
    }

    if (bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      _currentState = _currentState.copyWith(
        isConfigurationValid: false,
        configErrorEnum: ConfigErrorEnum.invalidToken,
      );
      logger.i(
        "BUGSEE: ${_currentState.configErrorEnum?.error}",
      );
      return;
    }
    _initializeBugsee(bugseeToken);
  }

  void _initializeBugsee(String bugseeToken) async {
    if (configurationData.isBugseeEnabled ?? true) {
      _isBugSeeInitialized = await _launchBugseeLogger(bugseeToken);
    }

    _currentState = _currentState.copyWith(
      isConfigurationValid: _isBugSeeInitialized,
      isBugseeEnabled: _isBugSeeInitialized,
      isVideoCaptureEnabled: _isBugSeeInitialized &&
          (configurationData.isVideoCaptureEnabled ?? true),
      isDataObscured: configurationData.isDataObscured,
      isLogFilterEnabled: configurationData.isLogsFilterEnabled,
      isLogCollectionEnabled: configurationData.isLogCollectionEnabled,
      attachLogFile: configurationData.attachLogFileEnabled,
    );
  }

  Future<bool> _launchBugseeLogger(String bugseeToken) async {
    bool isInitialized = false;
    HttpOverrides.global = Bugsee.defaultHttpOverrides;
    await Bugsee.launch(
      bugseeToken,
      appRunCallback: (isBugseeLaunched) {
        if (!isBugseeLaunched) {
          logger.e(
            "BUGSEE: not initialized, verify bugsee token configuration",
          );
        }
        isInitialized = isBugseeLaunched;
      },
      launchOptions: launchOptions,
    );
    if (configurationData.isLogsFilterEnabled ?? false) {
      Bugsee.setLogFilter(_filterBugseeLogs);
    }
    if (configurationData.attachLogFileEnabled ?? false) {
      Bugsee.setAttachmentsCallback(_attachLogFile);
    }
    return isInitialized;
  }

  BugseeLaunchOptions? _initializeLaunchOptions() {
    if (Platform.isAndroid) {
      return AndroidLaunchOptions()
        ..captureLogs = (configurationData.isLogCollectionEnabled ?? true);
    } else if (Platform.isIOS) {
      return IOSLaunchOptions()
        ..captureLogs = (configurationData.isLogCollectionEnabled ?? true);
    }
    return null;
  }

  Future<BugseeLogEvent> _filterBugseeLogs(BugseeLogEvent logEvent) async {
    logEvent.text = logEvent.text.replaceAll(RegExp(bugseeFilterRegex), '');
    return logEvent;
  }

  Future<List<BugseeAttachment>> _attachLogFile(BugseeReport report) async {
    var attachments = <BugseeAttachment>[];
    if (loggerManager.logFile != null) {
      attachments.add(
        BugseeAttachment(
          "logFile",
          loggerManager.logFile!.path,
          loggerManager.logFile!.readAsBytesSync(),
        ),
      );
    }
    return attachments;
  }

  @override
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
    Map<String, dynamic> traces = const {},
    Map<String, Map<String, dynamic>?> events = const {},
  }) async {
    if (_currentState.isBugseeEnabled) {
      for (var trace in traces.entries) {
        await Bugsee.trace(trace.key, trace.value);
      }
      for (var event in events.entries) {
        await Bugsee.event(event.key, event.value);
      }
      await Bugsee.logException(exception, stackTrace);
    }
  }

  @override
  Future<void> setIsBugseeEnabled(bool value) async {
    if (_currentState.isConfigurationValid) {
      await bugseeRepository.setIsBugseeEnabled(value);
      _currentState = _currentState.copyWith(
        isBugseeEnabled: value,
        isRestartRequired: value,
        isVideoCaptureEnabled: value,
        isDataObscured: value,
      );

      if (!_currentState.isRestartRequired) {
        await Bugsee.stop();
      }
    }
  }

  @override
  Future<void> setIsVideoCaptureEnabled(bool value) async {
    if (_currentState.isBugseeEnabled) {
      _currentState = _currentState.copyWith(
        isVideoCaptureEnabled: value,
      );
      await bugseeRepository.setIsVideoCaptureEnabled(
        _currentState.isVideoCaptureEnabled,
      );
      if (!_currentState.isVideoCaptureEnabled) {
        await Bugsee.pause();
      } else {
        await Bugsee.resume();
      }
    }
  }

  @override
  Future<void> showCaptureLogReport() async {
    if (_currentState.isBugseeEnabled) {
      await Bugsee.showReportDialog();
    }
  }

  @override
  Future<void> setIsDataObscured(bool value) async {
    if (_currentState.isBugseeEnabled) {
      await bugseeRepository.setIsDataObscure(value);
      _currentState = _currentState.copyWith(
        isRestartRequired: value != configurationData.isDataObscured,
        isDataObscured: value,
      );
    }
  }

  @override
  Future<void> setIsLogsCollectionEnabled(bool value) async {
    if (_currentState.isBugseeEnabled) {
      await bugseeRepository.setIsLogCollectionEnabled(value);
      _currentState = _currentState.copyWith(
        isRestartRequired: value != configurationData.isLogCollectionEnabled,
        isLogCollectionEnabled: value,
      );
      if (!value) {
        _currentState = _currentState.copyWith(
          isLogFilterEnabled: false,
        );
      }
    }
  }

  @override
  Future<void> setIsLogFilterEnabeld(bool value) async {
    if (_currentState.isBugseeEnabled && _currentState.isLogCollectionEnabled) {
      await bugseeRepository.setIsLogFilterEnabled(value);
      _currentState = _currentState.copyWith(
        isRestartRequired: value != configurationData.isLogsFilterEnabled,
        isLogFilterEnabled: value,
      );
    }
  }

  @override
  Future<void> setAttachLogFileEnabled(bool value) async {
    if (_currentState.isBugseeEnabled) {
      await bugseeRepository.setAttachLogFileEnabled(value);
      _currentState = _currentState.copyWith(
        isRestartRequired: value != configurationData.attachLogFileEnabled,
        attachLogFile: value,
      );
    }
  }

  @override
  Future<void> inteceptExceptions(
    Object error,
    StackTrace stackTrace,
  ) async {
    String? message = switch (error.runtimeType) {
      const (PersistenceException) => (error as PersistenceException).message,
      _ => null,
    };
    await logException(
      exception: Exception(error),
      stackTrace: stackTrace,
      traces: {
        'message': message,
      },
    );
  }

  @override
  Future<void> addAttributes(Map<String, dynamic> attributes) async {
    for (var attribute in attributes.entries) {
      await Bugsee.setAttribute(attribute.key, attribute.value);
    }
  }

  @override
  Future<void> clearAttribute(String attribute) async {
    await Bugsee.clearAttribute(attribute);
  }

  @override
  Future<void> addEmailAttribute(String email) async {
    await Bugsee.setEmail(email);
  }

  @override
  Future<void> clearEmailAttribute() async {
    await Bugsee.clearEmail();
  }

  @override
  Future<void> inteceptRenderExceptions(FlutterErrorDetails error) async {
    await logException(
      exception: Exception(error.exception),
      stackTrace: error.stack,
    );
  }
}
