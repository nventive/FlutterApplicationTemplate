import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/environment_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// A widget that displays the current environment.
final class EnvironmentDiagnosticWidget extends StatelessWidget {
  final DiagnosticsService _diagnosticsService =
      GetIt.I.get<DiagnosticsService>();

  EnvironmentDiagnosticWidget({super.key});

  void _disableDiagnostics(BuildContext context) async {
    var hasUserAgreed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text("Disable diagnostic"),
        content: const Text(
          "Are you sure you want to disable the diagnostic? If you proceed, you will need to reinstall the app to regain access to it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Ok"),
          ),
        ],
      ),
    );

    if (hasUserAgreed ?? false) {
      await _diagnosticsService.disableDiagnostics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Environment",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        const EnvironmentPickerWidget(),
        const SizedBox(height: 8),
        DiagnosticButton(
          label: "DISABLE DIAGNOSTIC",
          onPressed: () => _disableDiagnostics(context),
        ),
      ],
    );
  }
}
