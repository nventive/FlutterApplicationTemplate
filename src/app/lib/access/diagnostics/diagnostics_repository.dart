import 'package:app/access/persistence_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for Diagnostic Repository.
abstract interface class DiagnosticsRepository {
  factory DiagnosticsRepository(bool defaultIsEnabled) = _DiagnosticsRepository;

  /// Gets whether the diagnostic is enabled.
  Future<bool> checkDiagnosticEnabled();

  /// Sets the diagnostic as dismissed.
  Future disableDiagnostics();
}

/// Implementation of [DiagnosticRepository].
final class _DiagnosticsRepository implements DiagnosticsRepository {
  /// The key used to store the diagnostic dismissed state in shared preferences.
  final String _diagnosticDisabledKey = 'diagnosticDisabled';

  /// Whether we want the diagnostics to be accessible by default.
  final bool _defaultIsEnabled;

  _DiagnosticsRepository(this._defaultIsEnabled);

  @override
  Future<bool> checkDiagnosticEnabled() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final isDiagnosticDisabled =
        sharedPreferences.getBool(_diagnosticDisabledKey);

    return isDiagnosticDisabled != null
        ? !isDiagnosticDisabled
        : _defaultIsEnabled;
  }

  @override
  Future disableDiagnostics() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var isSaved = await sharedPreferences.setBool(
      _diagnosticDisabledKey,
      true,
    );

    if (!isSaved) {
      throw const PersistenceException();
    }
  }
}
