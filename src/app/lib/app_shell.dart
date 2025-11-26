import 'package:app/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The shell of the application.
final class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.theater_comedy),
            label: context.local.dadJokesPageLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite),
            label: context.local.favoriteDadJokesPageLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.verified_user),
            label: 'App Check',
          ),
        ],
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
      ),
    );
  }
}
