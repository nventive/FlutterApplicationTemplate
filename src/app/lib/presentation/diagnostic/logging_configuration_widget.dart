import 'package:app/business/logger/logger_manager.dart';
import 'package:app/presentation/diagnostic/diagnostic_switch.dart';
import 'package:flutter/material.dart';

/// Widget that handles logging configuration switching.
final class LoggingConfigurationWidget extends StatefulWidget {
  final LoggerManager _loggerManager;

  const LoggingConfigurationWidget(this._loggerManager, {super.key});

  @override
  State<LoggingConfigurationWidget> createState() {
    return _LoggingConfigurationState();
  }
}

final class _LoggingConfigurationState
    extends State<LoggingConfigurationWidget> {
  bool _restartRequired = false;
  late LoggerManager _loggerManager;

  @override
  void initState() {
    super.initState();
    _loggerManager = widget._loggerManager;
    _restartRequired = _loggerManager.hasConfigurationBeenChanged;
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
              "Logging configuration changed. Please restart the application to apply the changes.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        DiagnosticSwitch(
          label: 'Console logging',
          value: _loggerManager.isConsoleLoggingEnabled,
          onChanged: (value) async {
            await _loggerManager.setIsConsoleLoggingEnabled(value);

            setState(() {
              _restartRequired = _loggerManager.hasConfigurationBeenChanged;
            });
          },
        ),
        DiagnosticSwitch(
          label: 'File logging',
          value: _loggerManager.isFileLoggingEnabled,
          onChanged: (value) async {
            await _loggerManager.setIsFileLoggingEnabled(value);

            setState(() {
              _restartRequired = _loggerManager.hasConfigurationBeenChanged;
            });
          },
        ),
      ],
    );
  }
}
