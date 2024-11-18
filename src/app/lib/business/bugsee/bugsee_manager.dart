import 'dart:async';
import 'dart:io';

import 'package:app/access/bugsee/bugsee_configuration_data.dart';
import 'package:app/access/bugsee/bugsee_repository.dart';
import 'package:bugsee_flutter/bugsee_flutter.dart';
import 'package:flutter/foundation.dart';
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

  /// indicate if the app require a restart to reactivate the bugsee configurations
  ///
  /// `true` only if `isConfigurationValid == true` and bugsee is turned on
  bool get isRestartRequired;

  /// indicate if bugsee is enabled or not
  /// by default bugsee is enabled if `isConfigurationValid == true`.
  bool get isBugseeEnabled;

  /// indicate whether video capturing is enabled or not.
  /// enabled by default if `isBugseeEnabled == true`.
  ///
  /// cannot be true if `isBugseeEnabled == false`.
  bool get isVideoCaptureEnabled;

  /// indicate if bugsee configuration is valid
  /// config is valid if app in release mode and the provided token is valid
  /// following the [bugseeTokenFormat] regex.
  bool get isConfigurationValid;

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
  Future<void> setIsBugseeEnabled(bool isBugseeEnabled);

  /// Manually update the current enableVideoCapture flag in shared prefs and in current manager singleton.
  Future<void> setIsVideoCaptureEnabled(bool isBugseeEnabled);

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

  @override
  bool isRestartRequired = false;

  @override
  bool isBugseeEnabled = false;

  @override
  late bool isVideoCaptureEnabled = false;

  @override
  bool isConfigurationValid = true;

  late bool _isBugSeeInitialized;
  BugseeLaunchOptions? launchOptions;

  @override
  Future<void> initialize({
    String? bugseeToken,
  }) async {
    BugseeConfigurationData bugseeConfigurationData =
        await bugseeRepository.getBugseeConfiguration();

    launchOptions = initializeLaunchOptions();
    _isBugSeeInitialized = false;

    if (kDebugMode) {
      isConfigurationValid = false;
      logger.i("BUGSEE: deactivated in debug mode");
      return;
    }

    if (bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      isConfigurationValid = false;
      logger.i(
        "BUGSEE: token is null or invalid, bugsee won't be initialized",
      );
      return;
    }

    if (bugseeConfigurationData.isBugseeEnabled ?? true) {
      await launchBugseeLogger(bugseeToken);
    }

    isBugseeEnabled = _isBugSeeInitialized;
    isVideoCaptureEnabled = _isBugSeeInitialized &&
        (bugseeConfigurationData.isVideoCaptureEnabled ?? true);
  }

  Future launchBugseeLogger(String bugseeToken) async {
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

  BugseeLaunchOptions? initializeLaunchOptions() {
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
    if (isBugseeEnabled) {
      await Bugsee.logException(exception, stackTrace);
    }
  }

  @override
  Future<void> logUnhandledException({
    required Exception exception,
    StackTrace? stackTrace,
  }) async {
    if (isBugseeEnabled) {
      await Bugsee.logUnhandledException(exception);
    }
  }

  @override
  Future<void> setIsBugseeEnabled(bool value) async {
    if (isConfigurationValid) {
      isBugseeEnabled = value;
      await bugseeRepository.setIsBugseeEnabled(isBugseeEnabled);

      isRestartRequired = _isBugSeeInitialized && isBugseeEnabled;
      isVideoCaptureEnabled = isBugseeEnabled;

      if (!isRestartRequired) {
        await Bugsee.stop();
      }
    }
  }

  @override
  Future<void> setIsVideoCaptureEnabled(bool value) async {
    if (isBugseeEnabled) {
      isVideoCaptureEnabled = value;
      await bugseeRepository.setIsVideoCaptureEnabled(isVideoCaptureEnabled);
      if (!isVideoCaptureEnabled) {
        await Bugsee.pause();
      } else {
        await Bugsee.resume();
      }
    }
  }

  @override
  Future<void> showCaptureLogReport() async {
    if (isBugseeEnabled) {
      await Bugsee.showReportDialog();
    }
  }
}
