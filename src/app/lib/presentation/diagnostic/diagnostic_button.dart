import 'package:flutter/material.dart';

/// A button used for the diagnostic overlay.
final class DiagnosticButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DiagnosticButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        minimumSize: const Size(68, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
