import 'package:app/access/diagnostics/diagnostics_repository.dart';

/// Interface for the Diagnostic Service.
abstract interface class DiagnosticsService {
  factory DiagnosticsService(DiagnosticsRepository diagnosticRepository) =
      _DiagnosticsService;

  /// Gets whether the diagnostic was dismissed.
  Future<bool> checkDiagnosticDismissal();

  /// Sets the diagnostic as dismissed.
  Future dismissDiagnostics();
}

/// Implementation of [DiagnosticService].
final class _DiagnosticsService implements DiagnosticsService {
  final DiagnosticsRepository _diagnosticRepository;

  _DiagnosticsService(DiagnosticsRepository diagnosticRepository)
      : _diagnosticRepository = diagnosticRepository;

  @override
  Future<bool> checkDiagnosticDismissal() async {
    return _diagnosticRepository.checkDiagnosticDismissal();
  }

  @override
  Future dismissDiagnostics() async {
    return _diagnosticRepository.dismissDiagnostics();
  }
}
