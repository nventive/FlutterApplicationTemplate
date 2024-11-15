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

  bool get isRequireRestart;

  bool get bugseeIsEnabled;
  bool get captureVideoIsEnabled;
  bool get isValidConfiguration;

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
  bool isRequireRestart = false;

  @override
  bool bugseeIsEnabled = false;

  @override
  late bool captureVideoIsEnabled = false;

  @override
  bool isValidConfiguration = true;

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
      isValidConfiguration = false;
      logger.i("BUGSEE: deactivated in debug mode");
      return;
    }

    if (bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      isValidConfiguration = false;
      logger.i(
        "BUGSEE: token is null or invalid, bugsee won't be initialized",
      );
      return;
    }

    if (bugseeConfigurationData.isBugseeEnabled ?? true) {
      await launchBugseeLogger(bugseeToken);
    }

    bugseeIsEnabled = _isBugSeeInitialized;
    captureVideoIsEnabled = _isBugSeeInitialized &&
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
    if (bugseeIsEnabled) {
      await Bugsee.logException(exception, stackTrace);
    }
  }

  @override
  Future<void> logUnhandledException({
    required Exception exception,
    StackTrace? stackTrace,
  }) async {
    if (bugseeIsEnabled) {
      await Bugsee.logUnhandledException(exception);
    }
  }

  @override
  Future<void> setIsBugseeEnabled(bool isBugseeEnabled) async {
    if (isValidConfiguration) {
      await bugseeRepository.setIsBugseeEnabled(isBugseeEnabled);

      isRequireRestart = _isBugSeeInitialized && isBugseeEnabled;
      bugseeIsEnabled = isBugseeEnabled;
      captureVideoIsEnabled = bugseeIsEnabled;

      if (!isRequireRestart) {
        await Bugsee.stop();
      }
    }
  }

  @override
  Future<void> setIsVideoCaptureEnabled(bool isVideoCaptureEnabled) async {
    if (bugseeIsEnabled) {
      captureVideoIsEnabled = isVideoCaptureEnabled;
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
    if (bugseeIsEnabled) {
      await Bugsee.showReportDialog();
    }
  }
}
