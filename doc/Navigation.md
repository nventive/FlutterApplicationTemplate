# Navigation

This project uses the [go_router](https://pub.dev/packages/go_router) to handle navigation.

## Handling sections with bottom navigation bar

To handle pages that share a menu, we use a [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html).

## Registering routes

To register a new section, you must add a stateful branch.
Each branch represents a section. 
Each page you add below the primary route will have the shell and anything that comes with it (like the bottom navigation bar).
When you add a route nested in another route, if you navigate to that page and then navigate back, it will navigate back to the parent page.

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentPage(),
      routes: [
        GoRoute(
          path: 'child',
          builder: (context, state) => const ChildPage(),
        ),
      ],
    ),
  ],
),
```
If you want a page without the shell, you can declare the route outside of the `StatefulShellRoute`.

## How to navigate

To navigate, you can reference the `router`, which is a global variable in the project.
To navigate to a different page, you can use `go` or `push`.

Here are a few examples:

```dart
// This will go to the child page. If you press the back button on that page, you will be on the parent page.
router.go('/parent/child');

// This will push the unrelated page to the top of the current navigation stack.
router.push('/unrelated-page');

// This will replace the current navigation stack with the unrelated page.
router.go('/unrelated-page');
```

To change the section, you can simply navigate to a route created under the section's StatefulShellBranch.
