import 'package:app/business/environment/environment_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Widget that handles environment switching.
final class EnvironmentPickerWidget extends StatefulWidget {
  const EnvironmentPickerWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EnvironmentPickerWidgetState();
  }
}

class _EnvironmentPickerWidgetState extends State<EnvironmentPickerWidget> {
  final _environmentManager = GetIt.I<EnvironmentManager>();

  bool _restartRequired = false;
  late Enum selectedEnviroment;

  _EnvironmentPickerWidgetState() {
    selectedEnviroment =
        _environmentManager.next ?? _environmentManager.current;
    _restartRequired = selectedEnviroment != _environmentManager.current;
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
              "Environment changed. Please restart the application to apply the changes.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ..._environmentManager.environments.map(
          (environment) => Material(
            child: CheckboxListTile(
              value: environment == selectedEnviroment,
              key: ValueKey(environment),
              title: Text(environment.toString()),
              onChanged: (value) async {
                _environmentManager.setEnvironment(environment);

                setState(() {
                  selectedEnviroment = environment;
                  _restartRequired = environment != _environmentManager.current;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
