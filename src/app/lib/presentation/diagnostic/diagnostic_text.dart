import 'package:flutter/material.dart';

/// A text widget used for the diagnostic overlay.
final class DiagnosticText extends StatelessWidget {
  final String text;
  final Color? color;

  const DiagnosticText({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(color: color ?? Colors.white),
    );
  }
}
