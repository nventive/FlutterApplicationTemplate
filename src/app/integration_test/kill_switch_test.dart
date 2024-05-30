import 'package:app/access/kill_switch/kill_switch_repository.dart';
import 'package:app/access/kill_switch/kill_switch_repository_mock.dart';
import 'package:app/app.dart';
import 'package:app/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Test for the KillSwitch.
Future<void> killSwitchTest() async {
  testWidgets(
      'Do not navigate to KillSwitchPage when killswitch is not activated',
      (WidgetTester tester) async {
    // Arrange
    var killSwitchRepo =
        GetIt.I.get<KillSwitchRepository>() as KillSwitchRepositoryMock;

    await tester.pumpWidget(const App());

    // Act
    killSwitchRepo.setKillSwitchState(false);

    await tester.pumpAndSettle();

    // Assert
    var killSwitchPage = find.byKey(const Key('KillSwitchScaffold'));

    // Check if the KillSwitchPage is present in the widget tree.
    expect(killSwitchPage, findsNothing);
  });

  testWidgets('navigate to KillSwitchPage when killswitch is activated',
      (WidgetTester tester) async {
    // Arrange
    var killSwitchRepo =
        GetIt.I.get<KillSwitchRepository>() as KillSwitchRepositoryMock;

    await tester.pumpWidget(const App());

    // Act
    killSwitchRepo.setKillSwitchState(true);

    await tester.pumpAndSettle();

    // Assert
    var killSwitchPage = find.byKey(const Key('KillSwitchScaffold'));

    // Check if the KillSwitchPage is present in the widget tree.
    expect(killSwitchPage, findsOneWidget);

    expect(router.canPop(), false);
  });

  testWidgets('navigate out of KillSwitchPage when killswitch is deactivated',
      (WidgetTester tester) async {
    // Arrange
    var killSwitchRepo =
        GetIt.I.get<KillSwitchRepository>() as KillSwitchRepositoryMock;

    await tester.pumpWidget(const App());

    // Act
    killSwitchRepo.setKillSwitchState(true);

    await tester.pumpAndSettle();

    killSwitchRepo.setKillSwitchState(false);

    await tester.pumpAndSettle();

    // Assert
    var killSwitchPage = find.byKey(const Key('KillSwitchScaffold'));

    // Check if the KillSwitchPage is present in the widget tree.
    expect(killSwitchPage, findsNothing);
  });
}
