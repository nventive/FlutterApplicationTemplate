import 'package:app/app.dart';
import 'package:app/shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shell Test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(Shell), findsOneWidget);
  });
}
