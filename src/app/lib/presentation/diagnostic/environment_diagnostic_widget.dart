import 'package:app/presentation/diagnostic/environment_picker_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays the current environment.
final class EnvironmentDiagnosticWidget extends StatelessWidget {
  const EnvironmentDiagnosticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Environment",
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 8),
        EnvironmentPickerWidget(),
      ],
    );
  }
}
