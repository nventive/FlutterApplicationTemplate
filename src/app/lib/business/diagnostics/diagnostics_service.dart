import 'package:app/access/diagnostics/diagnostics_repository.dart';

/// Interface for the Diagnostic Service.
abstract interface class DiagnosticsService {
  factory DiagnosticsService(DiagnosticsRepository diagnosticRepository) =
      _DiagnosticsService;

  /// Gets whether the diagnostic was dismissed.
  Future<bool> checkDiagnosticDismissal();

  /// Sets the diagnostic as dismissed only for the remaining of the app cycle.
  void dismissDiagnostics();

  /// Disable the diagnostic overlay permanently.
  Future disableDiagnostics();
}

/// Implementation of [DiagnosticService].
final class _DiagnosticsService implements DiagnosticsService {
  final DiagnosticsRepository _diagnosticRepository;

  bool _isDismissed = false;

  _DiagnosticsService(DiagnosticsRepository diagnosticRepository)
      : _diagnosticRepository = diagnosticRepository;

  @override
  Future<bool> checkDiagnosticDismissal() async {
    final isEnabled = await _diagnosticRepository.checkDiagnosticEnabled();
    return !isEnabled || _isDismissed;
  }

  @override
  void dismissDiagnostics() {
    _isDismissed = true;
  }

  @override
  Future disableDiagnostics() {
    return _diagnosticRepository.disableDiagnostics();
  }
}
