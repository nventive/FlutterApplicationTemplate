import 'package:app/business/mocking/mocking_manager.dart';
import 'package:app/presentation/diagnostic/mocking_configuration_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final class MockingDiagnosticWidget extends StatefulWidget {
  const MockingDiagnosticWidget({super.key});

  @override
  _MockingDiagnosticWidgetState createState() =>
      _MockingDiagnosticWidgetState();
}

final class _MockingDiagnosticWidgetState extends State<MockingDiagnosticWidget> {
  final MockingManager _mockingManager = GetIt.I.get<MockingManager>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Mocking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        MockingConfigurationWidget(_mockingManager),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
