import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:flutter/material.dart';

/// A button used for the diagnostic overlay that can be selected.
final class SelectableDiagnosticButton extends StatelessWidget {
  const SelectableDiagnosticButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        children: <Widget>[
          DiagnosticButton(
            label: label,
            onPressed: onPressed,
          ),
          if (isSelected)
            Container(
              width: 68,
              height: 0.5,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
