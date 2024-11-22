import 'package:app/access/mocking/mocking_repository.dart';
import 'package:app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

import 'bugsee_test.dart';
import 'dad_jokes_page_test.dart';
import 'forced_update_test.dart';
import 'kill_switch_test.dart';

/// All integration tests are run here because of this issue: https://github.com/flutter/flutter/issues/135673
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await initializeComponents(isMocked: true);
  await registerBugseeManager(
    isMock: true,
    //A mock hexadecimal-based Bugsee token
    bugseeToken: '01234567-0123-0123-0123-0123456789AB',
  );

  tearDownAll(
    () async => await GetIt.I.get<MockingRepository>().setMocking(false),
  );

  await dadJokeTest();
  await killSwitchTest();
  await forcedUpdateTest();
  await bugseeSetupTest();
}
