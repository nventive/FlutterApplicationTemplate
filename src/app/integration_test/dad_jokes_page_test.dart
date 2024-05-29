import 'package:app/access/mocking/mocking_repository.dart';
import 'package:app/app.dart';
import 'package:app/app_router.dart';
import 'package:app/main.dart';
import 'package:app/presentation/dad_jokes/dad_joke_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await initializeComponents(isMocked: true);

  tearDownAll(
    () async => await GetIt.I.get<MockingRepository>().setMocking(false),
  );

  testWidgets('Get Dad Jokes', (WidgetTester tester) async {
    // Arrange

    // Act
    await tester.pumpWidget(const App());

    // Without this the dadjokesContainer isn't there yet.
    await tester.pumpAndSettle();

    // Assert
    var dadjokesContainer = find.byKey(const Key('DadJokesContainer'));

    var dadJokes = find.descendant(
      of: dadjokesContainer,
      matching: find.byType(DadJokeListItem),
    );

    expect(dadJokes, findsAtLeast(1));
  });

  group("Favorites", () {
    testWidgets('Can add joke to favorite', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const App());

      // Without this the dadjokesContainer isn't there yet.
      await tester.pumpAndSettle();

      var dadjokesContainer = find.byKey(const Key('DadJokesContainer'));

      var dadJokes = find.descendant(
        of: dadjokesContainer,
        matching: find.byType(DadJokeListItem),
      );

      // Act
      await tester.tap(dadJokes.last);
      router.go(favoriteDadJokesPagePath);
      await tester.pumpAndSettle();

      var favJokesContainer = find.byKey(const Key('FavoriteJokesContainer'));
      var favJokes = find.descendant(
        of: favJokesContainer,
        matching: find.byType(DadJokeListItem),
      );

      // Assert
      expect(favJokes, findsExactly(2));

      router.go(home);
      await tester.pumpAndSettle();
    });
  });
  
  testWidgets('Can remove joke from favorite', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    router.go(favoriteDadJokesPagePath);
    await tester.pumpAndSettle();

    var favJokesContainer = find.byKey(const Key('FavoriteJokesContainer'));
    var favJokes = find.descendant(
      of: favJokesContainer,
      matching: find.byType(DadJokeListItem),
    );

    // Act
    await tester.tap(favJokes.first);
    await tester.pumpAndSettle();

    favJokes = find.descendant(
      of: favJokesContainer,
      matching: find.byType(DadJokeListItem),
    );

    // Assert
    expect(favJokes, findsOne);

    router.go(home);
    await tester.pumpAndSettle();
  });
}
