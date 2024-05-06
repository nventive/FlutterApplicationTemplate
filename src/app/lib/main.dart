import 'dart:io';

import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/diagnostics/diagnostics_repository.dart';
import 'package:app/access/environment/environment_repository.dart';
import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/access/kill_switch/kill_switch_repository.dart';
import 'package:app/access/kill_switch/kill_switch_repository_mock.dart';
import 'package:app/access/logger/logger_repository.dart';
import 'package:app/app.dart';
import 'package:app/app_router.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/business/environment/environment_manager.dart';
import 'package:app/business/forced_update/update_required_service.dart';
import 'package:app/business/kill_switch/kill_switch_service.dart';
import 'package:app/firebase_options.dart';
import 'package:app/business/logger/logger_manager.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

late Logger _logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _registerAndLoadEnvironment();
  await _registerAndLoadLoggers();

  _logger.d("Initialized environment and logger.");

  await _initializeFirebaseServices();
  _logger.i("Firebase has been Initialized and registered in the container.");

  _registerHttpClient();
  _logger.i("HttpClient has been Initialized and registered in the container.");

  _registerRepositories();
  _logger
      .i("Repositories has been Initialized and registered in the container.");

  _registerServices();
  _logger.i("Services has been Initialized and registered in the container.");

  runApp(const App());

  GetIt.I.get<UpdateRequiredService>().waitForUpdateRequired().then((value) {
    _logger.d("Force update is now required.");
    router.go(forcedUpdatePagePath);
    _logger.i("Navigated to forced update page.");
  });

  GetIt.I
      .get<KillSwitchService>()
      .isKillSwitchActivatedStream()
      .listen((isActivated) {
    _logger.d("KillSwitch state has been changed.");
    if (isActivated) {
      router.go(killSwitchPagePath);
      _logger.i("KillSwitch is activated. Navigated to kill switch page.");
    } else if (currentPath == killSwitchPagePath) {
      router.go(home);
      _logger.i("Killswitch is deactivated. Navigated to home page.");
    }
  });
}

Future _registerAndLoadEnvironment() async {
  // Register environment services in the IoC.
  GetIt.I.registerSingleton(EnvironmentRepository());
  GetIt.I.registerSingleton(
    EnvironmentManager(
      GetIt.I.get<EnvironmentRepository>(),
    ),
  );

  // Loads the current environment.
  await GetIt.I
      .get<EnvironmentManager>()
      .load(const String.fromEnvironment('ENV'));
}

Future _registerAndLoadLoggers() async {
  // Register logging services in the IoC.
  GetIt.I.registerSingleton(LoggerRepository());
  GetIt.I.registerSingleton(
    LoggerManager(
      GetIt.I.get<LoggerRepository>(),
    ),
  );

  // Create a new instance of logger and insert it into the IoC.
  _logger = await GetIt.I.get<LoggerManager>().createLogInstance();
  GetIt.I.registerSingleton(_logger);
}

/// Initializes Firebase services.
Future _initializeFirebaseServices() async {
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration(
          minutes:
              int.parse(dotenv.env["REMOTE_CONFIG_FETCH_INTERVAL_MINUTES"]!),
        ),
      ),
    );
    await remoteConfig.setDefaults(const {
      "minimum_version": "1.0.0",
    });
  }
}

/// Registers the HTTP client.
void _registerHttpClient() {
  GetIt.I.registerSingleton<Dio>(Dio());
}

/// Registers the repositories.
void _registerRepositories() {
  GetIt.I.registerSingleton(
    DadJokesRepository(
      GetIt.I.get<Dio>(),
      baseUrl: dotenv.env["DAD_JOKES_BASE_URL"]!,
    ),
  );
  GetIt.I.registerSingleton(FavoriteDadJokesRepository());
  GetIt.I.registerSingleton(DiagnosticsRepository());

  /// Firebase remote config is either not supported on desktop platforms or in beta.
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    GetIt.I.registerSingleton(MinimumVersionRepository());
  } else {
    GetIt.I.registerSingleton<MinimumVersionRepository>(
      MinimumVersionRepositoryMock(),
    );
  }

  GetIt.I.registerSingleton(CurrentVersionRepository());
  GetIt.I.registerSingleton<KillSwitchRepository>(
    KillSwitchRepositoryMock(),
  );
}

/// Registers the services.
void _registerServices() {
  GetIt.I.registerSingleton(
    DadJokesService(
      GetIt.I.get<DadJokesRepository>(),
      GetIt.I.get<FavoriteDadJokesRepository>(),
      _logger,
    ),
  );
  GetIt.I.registerSingleton(
    DiagnosticsService(
      GetIt.I.get<DiagnosticsRepository>(),
    ),
  );

  GetIt.I.registerSingleton(
    UpdateRequiredService(
      GetIt.I.get<MinimumVersionRepository>(),
      GetIt.I.get<CurrentVersionRepository>(),
    ),
  );

  GetIt.I.registerSingleton(
    KillSwitchService(
      GetIt.I.get<KillSwitchRepository>(),
    ),
  );
}
