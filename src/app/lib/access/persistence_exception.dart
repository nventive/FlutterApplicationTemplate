/// Exception thrown when something couldn't be persisted in the shared preference.
/// It was created due to https://github.com/flutter/flutter/issues/146070.
final class PersistenceException implements Exception {
  /// A descriptive message detailing the persistence exception
  final String? message;

  const PersistenceException({this.message});
}
