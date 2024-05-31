import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/app.dart';
import 'package:app/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Test for the Forced update.
Future<void> forcedUpdateTest() async {
  testWidgets(
      'Navigate to ForcedUpdatePage when current version is lower than the minimum required version',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(const App());

    var currentVersionRepo = GetIt.I.get<CurrentVersionRepository>();

    var minimumVersionRepo =
        GetIt.I.get<MinimumVersionRepository>() as MinimumVersionRepositoryMock;

    var currentVersion = await currentVersionRepo.getCurrentVersion();

    var newMinimumVersion = Version(currentVersion.major + 1, 0, 0);

    // Act
    minimumVersionRepo.updateMinimumVersion(version: newMinimumVersion);

    await tester.pumpAndSettle();

    // Assert
    var forcedUpdateScaffold = find.byKey(const Key('forcedUpdateScaffold'));

    // Check if the ForcedUpdatePage is present in the widget tree.
    expect(forcedUpdateScaffold, findsOne);

    expect(router.canPop(), false);
  });
}
