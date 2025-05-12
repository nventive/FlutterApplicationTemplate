import 'package:alice/alice.dart';
import 'package:app/business/app_review/app_review_service.dart';
import 'package:app/business/logger/logger_manager.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/logging_configuration_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// A widget that provides tools to devs to configure and test logging in the app.
final class LoggerDiagnosticWidget extends StatelessWidget {
  final Logger _logger = GetIt.I.get<Logger>();
  final LoggerManager _loggerManager = GetIt.I.get<LoggerManager>();
  final Alice _alice = GetIt.I.get<Alice>();
  final AppReviewService _appReviewService = GetIt.I.get<AppReviewService>();

  LoggerDiagnosticWidget({super.key});

  void _showNativePrompt(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text("Diagnostic"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void _logError() {
    try {
      // Simulating an error by dividing by zero.
      // ignore: unused_local_variable
      final result = 42 ~/ 0;
    } catch (e, stackTrace) {
      _logger.e(
        'Forced error log. Please ignore.',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _testAllLogs(BuildContext context) async {
    _logger.t('Forced trace log. Please ignore.');
    _logger.d('Forced debug log. Please ignore.');
    _logger.i('Forced information log. Please ignore.');
    _logger.w('Forced warning log. Please ignore.');
    _logError();
    _logger.f('Forced fatal log. Please ignore.');

    _showNativePrompt(context, 'Check your console.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Loggers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        LoggingConfigurationWidget(_loggerManager),
        const SizedBox(height: 8.0),
        DiagnosticButton(
          label: 'TEST ALL LOG LEVELS',
          onPressed: () => _testAllLogs(context),
        ),
        DiagnosticButton(
          label: 'DELETE LOG FILE',
          onPressed: () async {
            final isFileDeleted = await _loggerManager.deleteLogFile();

            if (!context.mounted) {
              return;
            }

            _showNativePrompt(
              context,
              isFileDeleted
                  ? 'The log file was deleted.'
                  : 'Failed to deleted the log file.',
            );
          },
        ),
        DiagnosticButton(
          label: 'SHARE LOG FILE',
          onPressed: () async {
            final isShared = await _loggerManager.shareLogFile();

            if (!context.mounted) {
              return;
            }

            if (!isShared) {
              _showNativePrompt(context, 'Failed to share the log file.');
            }
          },
        ),
        DiagnosticButton(
          label: 'OPEN CONSOLE',
          onPressed: () => _alice.showInspector(),
        ),
        DiagnosticButton(
          label: 'PROMPT FOR REVIEW',
          onPressed: () async {
            await _appReviewService.promptForReview();
          },
        ),
      ],
    );
  }
}
