import 'dart:io';

import 'package:bugsee_flutter/bugsee_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:logger/web.dart';

abstract interface class BugseeManager {
  factory BugseeManager({
    required Logger logger,
  }) = _BugseeManager;

  Future<void> initialize({required VoidCallback runApp});
}

final class _BugseeManager implements BugseeManager {
  final Logger logger;

  late BugseeLaunchOptions launchOptions;
  String? bugseeAccessToken;

  _BugseeManager({required this.logger});

  @override
  Future<void> initialize({
    required VoidCallback runApp,
  }) async {
    await initializeTokensAndOptions();
    if (kDebugMode) {
      runApp();
      return;
    }

    if (bugseeAccessToken == null) {
      logger.i("bugsee token is null, bugsee won't be initialized");
    }
    HttpOverrides.global = Bugsee.defaultHttpOverrides;
    Bugsee.launch(
      bugseeAccessToken ?? '',
      appRunCallback: (isBugseeLaunched) {
        if (!isBugseeLaunched) {
          logger.e("bugsee is not initialized, verify bugsee token config");
        }
        runApp();
      },
      launchOptions: launchOptions,
    );
  }

  Future initializeTokensAndOptions() async {
    if (Platform.isAndroid) {
      launchOptions = AndroidLaunchOptions();
      bugseeAccessToken = dotenv.env['BUGSEE_ANDROID_TOKEN'];
    } else if (Platform.isIOS) {
      launchOptions = IOSLaunchOptions();
      bugseeAccessToken = dotenv.env['BUGSEE_IOS_TOKEN'];
    }
  }
}
