import 'dart:async';
import 'dart:io';
import 'package:app/access/bugsee/bugsee_configuration_data.dart';
import 'package:app/access/bugsee/bugsee_repository.dart';
import 'package:app/business/bugsee/bugsee_config_state.dart';
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
  factory BugseeManager({
    required Logger logger,
    required BugseeRepository bugseeRepository,
  }) = _BugseeManager;

  /// Current BugseeManager state
  BugseeConfigState get bugseeConfigState;

  /// Initialize bugsee with given token
  /// bugsee is not available in debug mode
  /// * [bugseeToken]: nullable bugsee token, if null bugsee won't be initialized make sure you provide
  /// [BUGSEE_TOKEN] in the env using `--dart-define` or `launch.json` on vscode
  Future<void> initialize({
    String? bugseeToken,
  });

  /// Manually log a provided exception with a stack trace
  /// (medium severity exception in Bugsee dashboard)
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? traces,
    Map<String, Map<String, dynamic>?>? events,
  });

  /// Manually log an unhandled exception with a stack trace
  /// (critical severity exception in Bugsee dashboard)
  Future<void> logUnhandledException({
    required Exception exception,
    StackTrace? stackTrace,
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
}

final class _BugseeManager implements BugseeManager {
  final Logger logger;
  final BugseeRepository bugseeRepository;

  _BugseeManager({
    required this.logger,
    required this.bugseeRepository,
  });

  BugseeConfigState _currentState = BugseeConfigState();

  @override
  BugseeConfigState get bugseeConfigState => _currentState;

  late bool _isBugSeeInitialized;
  late BugseeConfigurationData configurationData;
  BugseeLaunchOptions? launchOptions;

  @override
  Future<void> initialize({
    String? bugseeToken,
  }) async {
    configurationData = await bugseeRepository.getBugseeConfiguration();
    configurationData = configurationData.copyWith(
      isLogCollectionEnabled: configurationData.isLogCollectionEnabled ??
          bool.parse(
            dotenv.env['DISABLE_LOG_COLLECTION'] ?? 'true',
          ),
      isLogsFilterEnabled: configurationData.isLogsFilterEnabled ??
          bool.parse(
            dotenv.env['FILTER_LOG_COLLECTION'] ?? 'true',
          ),
      isDataObscured: configurationData.isDataObscured ??
          bool.parse(dotenv.env['IS_DATA_OBSCURE'] ?? 'true'),
    );

    launchOptions = _initializeLaunchOptions();
    _isBugSeeInitialized = false;

    if (kDebugMode) {
      _currentState = _currentState.copyWith(
        isConfigurationValid: false,
      );
      logger.i("BUGSEE: deactivated in debug mode");
      return;
    }

    if (bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      _currentState = _currentState.copyWith(
        isConfigurationValid: false,
      );
      logger.i(
        "BUGSEE: token is null or invalid, bugsee won't be initialized",
      );
      return;
    }

    _currentState = _currentState.copyWith(
      isLogFilterEnabled: configurationData.isLogsFilterEnabled,
      isLogCollectionEnabled: configurationData.isLogCollectionEnabled,
    );

    if (configurationData.isBugseeEnabled ?? true) {
      await _launchBugseeLogger(bugseeToken);
    }

    _currentState = _currentState.copyWith(
      isConfigurationValid: _isBugSeeInitialized,
      isBugseeEnabled: _isBugSeeInitialized,
      isVideoCaptureEnabled: _isBugSeeInitialized &&
          (configurationData.isVideoCaptureEnabled ?? true),
      isDataObscured: configurationData.isDataObscured,
    );
  }

  Future _launchBugseeLogger(String bugseeToken) async {
    HttpOverrides.global = Bugsee.defaultHttpOverrides;
    await Bugsee.launch(
      bugseeToken,
      appRunCallback: (isBugseeLaunched) {
        if (!isBugseeLaunched) {
          logger.e(
            "BUGSEE: not initialized, verify bugsee token configuration",
          );
        }
        _isBugSeeInitialized = isBugseeLaunched;
      },
      launchOptions: launchOptions,
    );
    if (_currentState.isLogFilterEnabled) {
      Bugsee.setLogFilter(_filterBugseeLogs);
    }
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

  @override
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? traces,
    Map<String, Map<String, dynamic>?>? events,
  }) async {
    if (_currentState.isBugseeEnabled) {
      if (traces != null) {
        for (var trace in traces.entries) {
          await Bugsee.trace(trace.key, trace.value);
        }
      }

      if (events != null) {
        for (var event in events.entries) {
          await Bugsee.event(event.key, event.value);
        }
      }

      await Bugsee.logException(exception, stackTrace);
    }
  }

  @override
  Future<void> logUnhandledException({
    required Exception exception,
    StackTrace? stackTrace,
  }) async {
    if (_currentState.isBugseeEnabled) {
      await Bugsee.logUnhandledException(exception);
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
}
