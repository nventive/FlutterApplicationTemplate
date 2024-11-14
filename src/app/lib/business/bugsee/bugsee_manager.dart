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

  bool get configurationHasChanged;

  bool get bugseeIsEnabled;
  bool get captureVideoIsEnabled;
  bool get isValidConfiguration;

  ///initialize bugsee with given token
  ///bugsee is not available in debug mode
  ///* [bugseeToken]: nullable bugsee token, if null bugsee won't be initialized make sure you provide
  ///[BUGSEE_TOKEN] in the env using `--dart-define` or `launch.json` on vscode
  Future<void> initialize({
    String? bugseeToken,
  });

  ///Manually log a provided exception with a stack trace
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
  });

  ///Manually update the current BugseeEnabled flag in shared prefs and in current manager singleton.
  Future<void> updateBugseeEnabledValue(bool isBugseeEnabled);

  ///Manually update the current enableVideoCapture flag in shared prefs and in current manager singleton.
  Future<void> updateIsVideoCuptureValue(bool isBugseeEnabled);

  ///Manually shows the built-in capture log report screen of Bugsee.
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
  bool configurationHasChanged = false;

  @override
  bool bugseeIsEnabled = false;

  @override
  late bool captureVideoIsEnabled = false;

  @override
  bool isValidConfiguration = true;

  late bool _isBugSeeInitialized;
  late BugseeLaunchOptions launchOptions;

  @override
  Future<void> initialize({
    String? bugseeToken,
  }) async {
    BugseeConfigurationData bugseeConfigurationData =
        await bugseeRepository.getBugseeConfiguration();

    initializeLaunchOptions();
    _isBugSeeInitialized = false;

    if (kDebugMode ||
        bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      isValidConfiguration = false;
      if (!kDebugMode) {
        logger.i(
          "BUGSEE: token is null or invalid, bugsee won't be initialized",
        );
      } else {
        logger.i("BUGSEE: deactivated in debug mode");
      }
      return;
    } else if (bugseeConfigurationData.isBugseeEnabled ?? true) {
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

    bugseeIsEnabled = _isBugSeeInitialized;
    captureVideoIsEnabled = _isBugSeeInitialized &&
        (bugseeConfigurationData.isVideoCaptureEnabled ?? true);
  }

  Future initializeLaunchOptions() async {
    if (Platform.isAndroid) {
      launchOptions = AndroidLaunchOptions();
    } else if (Platform.isIOS) {
      launchOptions = IOSLaunchOptions();
    }
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
  Future<void> updateBugseeEnabledValue(bool isBugseeEnabled) async {
    if (isValidConfiguration) {
      await bugseeRepository.setIsBugseeEnabled(isBugseeEnabled);
      bugseeIsEnabled = isBugseeEnabled;
      configurationHasChanged = bugseeIsEnabled != _isBugSeeInitialized;
      captureVideoIsEnabled = bugseeIsEnabled;
    }
  }

  @override
  Future<void> updateIsVideoCuptureValue(bool isVideoCaptureEnabled) async {
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
