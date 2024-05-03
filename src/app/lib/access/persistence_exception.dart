/// Exception thrown when something couldn't be persisted in the shared preference.
/// It was created due to https://github.com/flutter/flutter/issues/146070.
final class PersistenceException implements Exception {
  const PersistenceException();
}
