import 'package:app/app.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/shell.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';

import 'app_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DiagnosticsService>(),
  MockSpec<DadJokesService>(),
])
void main() {
  var diagnosticsService = MockDiagnosticsService();
  var dadJokesService = MockDadJokesService();

  setUp(() {
    diagnosticsService = MockDiagnosticsService();
    dadJokesService = MockDadJokesService();

    GetIt.I.registerSingleton<DiagnosticsService>(
      diagnosticsService,
    );
    GetIt.I.registerSingleton<DadJokesService>(
      dadJokesService,
    );
  });

  testWidgets('Shell Test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(Shell), findsOneWidget);
  });
}
