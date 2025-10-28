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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.theater_comedy),
            label: context.local.dadJokesPageLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: context.local.favoriteDadJokesPageLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: 'AI Chat', // TODO: Add localization
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
