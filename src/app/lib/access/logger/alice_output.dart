import 'package:alice/alice.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Custom implementation of [LogOutput] to add [Alice] logs writting support.
final class AliceOutput extends LogOutput {
  final Alice _alice;

  AliceOutput({required Alice alice})
      : _alice = alice,
        super();

  DiagnosticLevel _mapLogLevel(Level level) {
    switch (level) {
      case Level.trace:
        return DiagnosticLevel.debug;
      case Level.debug:
        return DiagnosticLevel.debug;
      case Level.info:
        return DiagnosticLevel.info;
      case Level.warning:
        return DiagnosticLevel.warning;
      case Level.error:
        return DiagnosticLevel.error;
      case Level.fatal:
        return DiagnosticLevel.error;
      default:
        return DiagnosticLevel.debug;
    }
  }

  @override
  void output(OutputEvent event) {
    _alice.addLog(
      AliceLog(
        level: _mapLogLevel(event.origin.level),
        message: event.origin.message,
        error: event.origin.error,
        stackTrace: event.origin.stackTrace,
      ),
    );
  }
}
