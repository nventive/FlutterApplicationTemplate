import 'package:app/access/environment/environment_repository.dart';
import 'package:app/business/environment/environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to use as the source of truth for application environment (e.g. Staging, Production, etc.).
abstract interface class EnvironmentManager {
  factory EnvironmentManager(EnvironmentRepository repository) =
      _EnvironmentManager;

  /// Gets the current environment (which can be overridden).
  Environment get current;

  /// Gets the next environment that will become the current one when the application restarts.
  /// This value changes when using [setEnvironment].
  Environment? get next;

  // Gets a list of all environments.
  List<Environment> get environments;

  /// Loads the environment.
  Future<void> load(String defaultEnvironment);

  /// Sets the environment to apply on next app launch.
  Future setEnvironment(Environment environment);
}

/// Implementation of [EnvironmentManager].
final class _EnvironmentManager implements EnvironmentManager {
  /// Map of environment names to their respective environment file names.
  final Map<Environment, String> _environmentFileNames = {
    Environment.development: '.env.dev',
    Environment.staging: '.env.staging',
    Environment.production: '.env.prod',
  };

  final Map<Environment, String> _bugseeFileName = {
    Environment.development: '.bugsee.dev',
    Environment.staging: '.bugsee.dev',
    Environment.production: '.bugsee.dev',
  };

  @override
  late List<Environment> environments;

  @override
  late Environment current;

  @override
  late Environment? next;

  final EnvironmentRepository _repository;

  _EnvironmentManager(this._repository);

  @override
  Future<void> load(String defaultEnvironment) async {
    environments = _environmentFileNames.entries.map((e) => e.key).toList();

    final persistedEnvironment = await _repository.getEnvironment();
    final selectedEnvironment = persistedEnvironment ?? defaultEnvironment;
    current = Environment.values.firstWhere(
      (environment) => environment.toString() == selectedEnvironment,
    );
    next = null;

    await dotenv.load(
      fileName: _bugseeFileName[current]!,
    );
    Map<String, String> bugSeeTokens = {
      'BUGSEE_ANDROID_TOKEN': dotenv.env['BUGSEE_ANDROID_TOKEN']!,
      'BUGSEE_IOS_TOKEN': dotenv.env['BUGSEE_IOS_TOKEN']!,
    };
    await dotenv.load(
      fileName: _environmentFileNames[current]!,
      mergeWith: bugSeeTokens,
    );
  }

  @override
  Future setEnvironment(Environment environment) async {
    await _repository.setEnvironment(environment.toString());
    next = environment;
  }
}
