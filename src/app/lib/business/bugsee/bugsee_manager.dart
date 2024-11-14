import 'dart:io';

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
  }) = _BugseeManager;

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
}

final class _BugseeManager implements BugseeManager {
  final Logger logger;

  late BugseeLaunchOptions launchOptions;

  late bool _isBugSeeInitialized;

  _BugseeManager({
    required this.logger,
  });

  @override
  Future<void> initialize({
    String? bugseeToken,
  }) async {
    initializeLaunchOptions();
    _isBugSeeInitialized = false;
    if (kDebugMode) {
      logger.i("BUGSEE: deactivated in debug mode");
      return;
    }

    if (bugseeToken == null ||
        !RegExp(bugseeTokenFormat).hasMatch(bugseeToken)) {
      logger.i("BUGSEE: token is null or invalid, bugsee won't be initialized");
      return;
    }

    HttpOverrides.global = Bugsee.defaultHttpOverrides;
    await Bugsee.launch(
      bugseeToken,
      appRunCallback: (isBugseeLaunched) {
        if (!isBugseeLaunched) {
          logger
              .e("BUGSEE: not initialized, verify bugsee token configuration");
        }
        _isBugSeeInitialized = isBugseeLaunched;
      },
      launchOptions: launchOptions,
    );
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
    if (_isBugSeeInitialized) {
      await Bugsee.logException(exception, stackTrace);
    }
  }
}
