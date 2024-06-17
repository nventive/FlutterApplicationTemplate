import 'package:app/access/review_source/custom_review_service.dart';
import 'package:app/business/mocking/mocking_manager.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/diagnostic_switch.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:review_service/src/review_service/review_prompter.dart';
import 'package:flutter/material.dart';

/// Widget that handles logging configuration switching.
final class MockingConfigurationWidget extends StatefulWidget {
  final MockingManager _mockingManager;

  const MockingConfigurationWidget(MockingManager mockingManager, {super.key})
      : _mockingManager = mockingManager;

  @override
  State<MockingConfigurationWidget> createState() {
    return _MockingConfigurationWidgetState();
  }
}

final class _MockingConfigurationWidgetState
    extends State<MockingConfigurationWidget> {
  bool _restartRequired = false;
  late MockingManager _mockingManager;
  late ReviewPrompter _reviewPrompter;
  late CustomReviewService _reviewService;

  @override
  void initState() {
    super.initState();
    _mockingManager = widget._mockingManager;
    _reviewPrompter = ReviewPrompter(logger: Logger());
    _reviewService = GetIt.I.get<CustomReviewService>();
    _restartRequired = _mockingManager.hasConfigurationBeenChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_restartRequired)
          Container(
            color: const Color.fromARGB(170, 255, 0, 0),
            child: const Text(
              "Mocking configuration changed. Please restart the application to apply the changes.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        DiagnosticSwitch(
          label: 'Data mocking',
          value: _mockingManager.isMockingEnabled,
          onChanged: (value) async {
            await _mockingManager.setIsMockingEnabled(value);

            setState(() {
              _restartRequired = _mockingManager.hasConfigurationBeenChanged;
            });
          },
        ),
        DiagnosticButton(
          label: 'Try prompt star review',
          onPressed: () async {
            if (await _reviewService.getAreConditionsSatisfied()) {
              _reviewPrompter.tryPrompt();
            } else {
              Logger().log(Level.debug, 'conditions not satisfied');
            }
          },
        ),
      ],
    );
  }
}
