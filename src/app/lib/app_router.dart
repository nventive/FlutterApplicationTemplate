import 'package:app/presentation/dad_jokes/dad_jokes_page.dart';
import 'package:app/presentation/dad_jokes/favorite_dad_jokes.dart';
import 'package:app/presentation/router_examples/setting_page.dart';
import 'package:app/presentation/router_examples/sub_page_with_menu_page.dart';
import 'package:app/presentation/router_examples/sub_page_without_menu_page.dart';
import 'package:app/shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();

const String dadJokesPagePath = '/';
const String favoriteDadJokesPagePath = '/favorites';
const String subPageWithoutMenuPath = '/sub-page-without-menu';
const String subPageWithMenuPath = 'sub-page';
const String settingPagePath = '/settings';
const String subPageWithMenuCompletePath = '/settings/sub-page';

final router = GoRouter(
  observers: [GoRouterObserver()],
  initialLocation: dadJokesPagePath,
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Shell routes are used to create pages with a shell.
    // StatefulShellRoutes save the state of each branch, allowing you to navigate between them without losing state.
    // An index stack is a stack of widgets that are indexed by an integer value,
    // that allows you to switch between them, while keeping their state.
    // IndexedStack is the recommended way by the flutter team to handle stateful shell routes.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          Shell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          // We can provide a navigator key if we want to use it elsewhere.
          // But it is not necessary. A default one will be generated if not provided.
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: dadJokesPagePath,
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: settingPagePath,
              builder: (context, state) => const SettingPage(),
              routes: [
                GoRoute(
                  path: subPageWithMenuPath,
                  builder: (context, state) => const SubPageWithMenuPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: subPageWithoutMenuPath,
      builder: (context, state) => const SubPageWithoutMenuPage(),
    ),
  ],
);

class GoRouterObserver extends NavigatorObserver {
  final Logger _logger = Logger();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _logger.i('Pushing ${route.settings.name}.');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _logger.i('Popped ${route.settings.name}.');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      _logger.i('Removed ${route.settings.name}.');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      _logger.i(
        'Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}.',
      );
    }
  }
}

// Temporary logger.
class Logger {
  void i(String message) {
    print(message);
  }
}
