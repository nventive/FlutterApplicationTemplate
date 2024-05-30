import 'dart:io';

import 'package:alice/alice.dart';
import 'package:app/access/dad_jokes/dad_jokes_mocked_repository.dart';
import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_mocked_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/diagnostics/diagnostics_repository.dart';
import 'package:app/access/environment/environment_repository.dart';
import 'package:app/access/firebase/firebase_repository.dart';
import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/access/kill_switch/kill_switch_repository.dart';
import 'package:app/access/kill_switch/kill_switch_repository_mock.dart';
import 'package:app/access/logger/logger_repository.dart';
import 'package:app/access/mocking/mocking_repository.dart';
import 'package:app/app.dart';
import 'package:app/app_router.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/business/environment/environment.dart';
import 'package:app/business/environment/environment_manager.dart';
import 'package:app/business/forced_update/update_required_service.dart';
import 'package:app/business/kill_switch/kill_switch_service.dart';
import 'package:app/business/logger/logger_manager.dart';
import 'package:app/business/mocking/mocking_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

late Logger _logger;

Future<void> main() async {
  await initializeComponents();

  runApp(const App());
}

Future initializeComponents({bool? isMocked}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _registerAndLoadEnvironment();
  await _registerAndLoadLoggers();

  _logger.d("Initialized environment and logger.");

  _registerHttpClient();
  _logger.i("HttpClient has been Initialized and registered in the container.");

  await _registerRepositories(isMocked);
  _logger
      .i("Repositories has been Initialized and registered in the container.");

  _registerServices();
  _logger.i("Services has been Initialized and registered in the container.");

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
    if (isActivated && currentPath != forcedUpdatePagePath) {
      router.go(killSwitchPagePath);
      _logger.i("KillSwitch is activated. Navigated to kill switch page.");
    } else if (!isActivated && currentPath == killSwitchPagePath) {
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

  await GetIt.I
      .get<EnvironmentManager>()
      .setEnvironment(Environment.development);

  // Loads the current environment.
  await GetIt.I
      .get<EnvironmentManager>()
      .load(const String.fromEnvironment('ENV'));
}

Future _registerAndLoadLoggers() async {
  // Register logging services in the IoC.
  GetIt.I.registerSingleton(LoggerRepository());
  GetIt.I.registerSingleton(
    Alice(
      showNotification: false,
      navigatorKey: rootNavigatorKey,
    ),
  );
  GetIt.I.registerSingleton(
    LoggerManager(
      loggerRepository: GetIt.I.get<LoggerRepository>(),
      alice: GetIt.I.get<Alice>(),
    ),
  );

  // Create a new instance of logger and insert it into the IoC.
  _logger = await GetIt.I.get<LoggerManager>().createLogInstance();
  GetIt.I.registerSingleton(_logger);
}

/// Registers the HTTP client.
void _registerHttpClient() {
  final dio = Dio();

  dio.interceptors.add(GetIt.I.get<Alice>().getDioInterceptor());

  GetIt.I.registerSingleton<Dio>(dio);
}

/// Registers the repositories.
Future<void> _registerRepositories(bool? isMocked) async {
  var mockingRepo = GetIt.I.registerSingleton(MockingRepository());

  // If the mocking state is not provided, we will check the current state.
  isMocked ??= await mockingRepo.isMockingEnabled();

  if (isMocked) {
    GetIt.I.get<MockingRepository>().setMocking(isMocked);
    GetIt.I.registerSingleton<DadJokesRepository>(DadJokesMockedRepository());
    GetIt.I.registerSingleton<FavoriteDadJokesRepository>(
      FavoriteDadJokesMockedRepository(),
    );
  } else {
    GetIt.I.registerSingleton(
      DadJokesRepository(
        GetIt.I.get<Dio>(),
        baseUrl: dotenv.env["DAD_JOKES_BASE_URL"]!,
      ),
    );
    GetIt.I.registerSingleton(FavoriteDadJokesRepository());
  }

  GetIt.I.registerSingleton(
    DiagnosticsRepository(
      bool.parse(dotenv.env["DIAGNOSTIC_ENABLED"] ?? 'false'),
    ),
  );
  GetIt.I
      .registerSingleton(
        MockingManager(
          GetIt.I.get<MockingRepository>(),
        ),
      )
      .initialize();

  /// Firebase remote config is either not supported on desktop platforms or in beta.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux || isMocked) {
    GetIt.I.registerSingleton<MinimumVersionRepository>(
      MinimumVersionRepositoryMock(),
    );
    GetIt.I.registerSingleton<KillSwitchRepository>(
      KillSwitchRepositoryMock(),
    );
  } else {
    var fireBaseRemoteConfigRepository =
        FirebaseRemoteConfigRepository(_logger);

    GetIt.I.registerSingleton<MinimumVersionRepository>(
      fireBaseRemoteConfigRepository,
    );
    GetIt.I.registerSingleton<KillSwitchRepository>(
      fireBaseRemoteConfigRepository,
    );
  }

  GetIt.I.registerSingleton(CurrentVersionRepository());
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
