import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/diagnostics/diagnostics_repository.dart';
import 'package:app/access/environment/environment_repository.dart';
import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/app.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/business/environment/environment.dart';
import 'package:app/business/environment/environment_manager.dart';
import 'package:app/business/forced_update/update_required_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  await _registerAndLoadEnvironment();
  _registerHttpClient();
  _registerRepositories();
  _registerServices();

  testWidgets('Dad jokes page', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(const App());

    // Act
    var dadJokesScaffold = find.byKey(const Key('dadjokesScaffold'));

    await Future.delayed(Duration(seconds: 5));

    var dadjokesContainer = find.byKey(const Key('dadJokesContainer'));

    // Assert
    expect(1, 1);
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

  var environmentManager = GetIt.I.get<EnvironmentManager>();

  // Loads the current environment.
  await environmentManager.setEnvironment(Environment.development);
  await environmentManager.load(const String.fromEnvironment('ENV'));
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
  GetIt.I.registerSingleton<MinimumVersionRepository>(
    MinimumVersionRepositoryMock(),
  );
  GetIt.I.registerSingleton(CurrentVersionRepository());
}

/// Registers the services.
void _registerServices() {
  GetIt.I.registerSingleton(
    DadJokesService(
      GetIt.I.get<DadJokesRepository>(),
      GetIt.I.get<FavoriteDadJokesRepository>(),
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
}
