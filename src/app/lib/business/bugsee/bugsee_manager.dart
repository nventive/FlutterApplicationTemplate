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

///Service related to initializing Bugsee service
abstract interface class BugseeManager {
  factory BugseeManager({
    required Logger logger,
    required BugseeRepository bugseeRepository,
  }) = _BugseeManager;

  /// Current BugseeManager state
  BugseeConfigState get bugseeConfigState;

  /// initialize bugsee with given token
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
}

final class _BugseeManager implements BugseeManager {
  final Logger logger;
  final BugseeRepository bugseeRepository;

  _BugseeManager({
    required this.logger,
    required this.bugseeRepository,
  });

  bool _initialDataObscuredState = false;
  BugseeConfigState _currentState = BugseeConfigState();

  @override
  BugseeConfigState get bugseeConfigState => _currentState;

  late bool _isBugSeeInitialized;
  BugseeLaunchOptions? launchOptions;

  @override
  Future<void> initialize({
    String? bugseeToken,
  }) async {
    BugseeConfigurationData bugseeConfigurationData =
        await bugseeRepository.getBugseeConfiguration();

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

    if (bugseeConfigurationData.isBugseeEnabled ?? true) {
      await _launchBugseeLogger(bugseeToken);
    }

    var isDataObscured = bugseeConfigurationData.isDataObscrured ??
        bool.parse(dotenv.env['IS_DATA_OBSCURE'] ?? 'false');

    _currentState = _currentState.copyWith(
      isConfigurationValid: _isBugSeeInitialized,
      isBugseeEnabled: _isBugSeeInitialized,
      isVideoCaptureEnabled: _isBugSeeInitialized &&
          (bugseeConfigurationData.isVideoCaptureEnabled ?? true),
      isDataObscured: isDataObscured,
    );
    _initialDataObscuredState = isDataObscured;
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
  }

  BugseeLaunchOptions? _initializeLaunchOptions() {
    if (Platform.isAndroid) {
      return AndroidLaunchOptions();
    } else if (Platform.isIOS) {
      return IOSLaunchOptions();
    }
    return null;
  }

  @override
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
  }) async {
    if (_currentState.isBugseeEnabled) {
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
        isRestartRequired: value != _initialDataObscuredState,
        isDataObscured: value,
      );
    }
  }
}
