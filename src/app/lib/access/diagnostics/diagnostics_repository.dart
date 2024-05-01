import 'package:shared_preferences/shared_preferences.dart';

/// Interface for Diagnostic Repository.
abstract interface class DiagnosticsRepository {
  factory DiagnosticsRepository() = _DiagnosticsRepository;

  /// Gets whether the diagnostic was dismissed.
  Future<bool> checkDiagnosticDismissal();

  /// Sets the diagnostic as dismissed.
  Future dismissDiagnostics();
}

/// Implementation of [DiagnosticRepository].
final class _DiagnosticsRepository implements DiagnosticsRepository {
  /// The key used to store the diagnostic dismissed state in shared preferences.
  final String _diagnosticDismissedKey = 'diagnosticDismissed';

  @override
  Future<bool> checkDiagnosticDismissal() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final wasDiagnosticDismissed =
        sharedPreferences.getBool(_diagnosticDismissedKey) ?? false;

    return wasDiagnosticDismissed;
  }

  @override
  Future dismissDiagnostics() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(
      _diagnosticDismissedKey,
      true,
    );
  }
}
