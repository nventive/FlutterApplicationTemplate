import 'package:app/access/mocking/mocking_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MockingDiagnosticWidget extends StatefulWidget {
  const MockingDiagnosticWidget({super.key});

  @override
  _MockingDiagnosticWidgetState createState() =>
      _MockingDiagnosticWidgetState();
}

class _MockingDiagnosticWidgetState extends State<MockingDiagnosticWidget> {
  final MockingRepository _mockingRepository = GetIt.I.get<MockingRepository>();
  bool _isMockingEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchSwitchState();
  }

  Future<void> _fetchSwitchState() async {
    var result = await _mockingRepository.checkMockingEnabled();

    setState(() {
      _isMockingEnabled = result;
    });
  }

  Future<void> _toggleSwitch(bool value) async {
    await _mockingRepository.setMocking(value);

    setState(() {
      _isMockingEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Switch(
          value: _isMockingEnabled, onChanged: (value) => _toggleSwitch(value)),
    );
  }
}
