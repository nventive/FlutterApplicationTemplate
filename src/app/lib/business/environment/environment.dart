/// Enum representing all available environments.
enum Environment {
  development,
  staging,
  production;

  @override
  String toString() => switch (this) {
        development => 'Development',
        staging => 'Staging',
        production => 'Production',
      };
}
