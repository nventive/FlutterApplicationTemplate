import 'package:app/presentation/diagnostic/diagnostic_overlay.dart';
import 'package:flutter/material.dart';

/// The shell of the application with [DiagnosticOverlay].
final class Shell extends StatelessWidget {
  const Shell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Add global widgets here.
        const DiagnosticOverlay(),
      ],
    );
  }
}
