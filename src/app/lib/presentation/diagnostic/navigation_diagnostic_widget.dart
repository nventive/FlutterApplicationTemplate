import 'package:app/app_router.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:flutter/material.dart';

/// A widget that has button that allows you to do navigation actions.
final class NavigationDiagnosticWidget extends StatelessWidget {
  const NavigationDiagnosticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              DiagnosticButton(
                label: "Go to the dad jokes page",
                onPressed: () {
                  router.go(dadJokesPagePath);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
