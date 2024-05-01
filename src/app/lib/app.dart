import 'package:app/app_router.dart';
import 'package:app/presentation/diagnostic/diagnostic_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              // Add global widgets here.
              const DiagnosticOverlay(),
            ],
          );
        },
      ),
    );
  }
}
