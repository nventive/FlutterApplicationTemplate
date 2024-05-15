import 'package:app/shell.dart';
import 'package:app/presentation/dad_jokes/dad_jokes_page.dart';
import 'package:app/presentation/dad_jokes/favorite_dad_jokes.dart';
import 'package:app/presentation/forced_update/forced_update_page.dart';
import 'package:app/presentation/kill_switch/kill_switch_page.dart';
import 'package:app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();

const String home = '/';
const String favoriteDadJokesPagePath = '/favorites';
const String forcedUpdatePagePath = '/forcedUpdate';
const String killSwitchPagePath = '/killswitch';
String? currentPath;

final router = GoRouter(
  observers: [GoRouterObserver(GetIt.I.get<Logger>())],
  initialLocation: home,
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      builder: (context, state, child) => Shell(child: child),
      routes: [
        // Shell routes are used to create pages with a shell.
        // StatefulShellRoutes save the state of each branch, allowing you to navigate between them without losing state.
        // An index stack is a stack of widgets that are indexed by an integer value,
        // that allows you to switch between them, while keeping their state.
        // IndexedStack is the recommended way by the flutter team to handle stateful shell routes.
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              // We can provide a navigator key if we want to use it elsewhere.
              // But it is not necessary. A default one will be generated if not provided.
              navigatorKey: _homeNavigatorKey,
              routes: [
                GoRoute(
                  path: home,
                  builder: (context, state) => const DadJokesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: favoriteDadJokesPagePath,
                  builder: (context, state) => const FavoriteDadJokesPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: forcedUpdatePagePath,
          builder: (context, state) => ForcedUpdatePage(),
        ),
      ],
    ),
    GoRoute(
      path: forcedUpdatePagePath,
      builder: (context, state) => ForcedUpdatePage(),
    ),
    GoRoute(
      path: killSwitchPagePath,
      builder: (context, state) {
        return const KillSwitchPage();
      },
    ),
  ],
);

class GoRouterObserver extends NavigatorObserver {
  final Logger _logger;

  GoRouterObserver(this._logger);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      currentPath = route.settings.name;

      _logger.i('Pushing ${route.settings.name}.');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      currentPath = route.settings.name;

      _logger.i('Popped ${route.settings.name}.');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      currentPath = route.settings.name;

      _logger.i('Removed ${route.settings.name}.');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      currentPath = newRoute?.settings.name;

      _logger.i(
        'Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}.',
      );
    }
  }
}
