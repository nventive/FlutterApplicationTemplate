import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/business/forced_update/update_required_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_required_service_test.mocks.dart';

@GenerateNiceMocks(
  [
    MockSpec<CurrentVersionRepository>(),
  ],
)
void main() {
  late CurrentVersionRepository currentVersionRepository;
  final MinimumVersionRepositoryMock minimumVersionRepositoryMock =
      MinimumVersionRepositoryMock();
  late UpdateRequiredService updateRequiredService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    var versionDummy = const Version(1, 5, 0);
    provideDummy(versionDummy);
    currentVersionRepository = MockCurrentVersionRepository();
    when(currentVersionRepository.getCurrentVersion()).thenAnswer(
      (_) async => versionDummy,
    );

    updateRequiredService = UpdateRequiredService(
      minimumVersionRepositoryMock,
      currentVersionRepository,
    );
  });

  group('Minimum version tests', () {
    var testCases = [
      {'version': const Version(2, 0, 0), 'expected': true},
      {'version': const Version(1, 0, 0), 'expected': false},
      {'version': const Version(1, 5, 0), 'expected': false},
    ];

    for (var testCase in testCases) {
      test('Minimum version ${testCase['version']} test', () async {
        // Arrange
        bool updateRequired = false;

        var updateRequiredFuture =
            updateRequiredService.waitForUpdateRequired().then((value) {
          updateRequired = true;
        });

        // Act
        minimumVersionRepositoryMock.updateMinimumVersion(
          version: testCase['version'] as Version,
        );

        var timeout = Future.delayed(const Duration(milliseconds: 10));

        await Future.any([timeout, updateRequiredFuture]);

        // Assert
        expect(updateRequired, testCase['expected']);
      });
    }
  });
}
