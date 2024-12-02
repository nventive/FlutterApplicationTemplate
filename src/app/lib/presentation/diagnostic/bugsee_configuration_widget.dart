import 'dart:math';

import 'package:app/business/bugsee/bugsee_config_state.dart';
import 'package:app/business/bugsee/bugsee_manager.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/diagnostic_switch.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BugseeConfigurationWidget extends StatefulWidget {
  const BugseeConfigurationWidget({super.key});

  @override
  State<BugseeConfigurationWidget> createState() =>
      _BugseeConfigurationWidgetState();
}

class _BugseeConfigurationWidgetState extends State<BugseeConfigurationWidget> {
  final BugseeManager bugseeManager = GetIt.I.get<BugseeManager>();

  late BugseeConfigState state;

  @override
  void initState() {
    super.initState();
    state = bugseeManager.bugseeConfigState;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            if (!state.isConfigurationValid)
              Container(
                color: const Color.fromARGB(170, 255, 0, 0),
                child: Text(
                  state.configErrorEnum?.error ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            if (state.isRestartRequired)
              Container(
                color: const Color.fromARGB(170, 255, 0, 0),
                child: const Text(
                  "Bugsee configuration changed. Please restart the application to apply the changes.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            DiagnosticSwitch(
              label: 'Bugsee enabled',
              value: state.isBugseeEnabled,
              onChanged: (value) async {
                await bugseeManager.setIsBugseeEnabled(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Video capture enabled',
              value: state.isVideoCaptureEnabled,
              onChanged: (value) async {
                await bugseeManager.setIsVideoCaptureEnabled(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Obscure data',
              value: state.isDataObscured,
              onChanged: (value) async {
                await bugseeManager.setIsDataObscured(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Log collection enabled',
              value: state.isLogCollectionEnabled,
              onChanged: (value) async {
                await bugseeManager.setIsLogsCollectionEnabled(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Filter log enabled',
              value: state.isLogFilterEnabled,
              onChanged: (value) async {
                await bugseeManager.setIsLogFilterEnabeld(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Log file attached',
              value: state.attachLogFile,
              onChanged: (value) async {
                bugseeManager.setAttachLogFileEnabled(value);
                setState(() {
                  state = bugseeManager.bugseeConfigState;
                });
              },
            ),
          ],
        ),
        DiagnosticButton(
          label: 'Log an exception',
          onPressed: () {
            bugseeManager.logException(exception: Exception());
          },
        ),
        DiagnosticButton(
          label: 'Add events to the exception',
          onPressed: () {
            bugseeManager.logEvents(
              {
                'data': {
                  'date': DateTime.now().millisecondsSinceEpoch,
                  'id': Random().nextInt(20),
                },
              },
            );
          },
        ),
        DiagnosticButton(
          label: 'Add email attributes',
          onPressed: () {
            bugseeManager.addEmailAttribute('john.doe@nventive.com');
          },
        ),
        DiagnosticButton(
          label: 'Add name attribute',
          onPressed: () {
            bugseeManager.addAttributes({
              'name': 'John Doe',
            });
          },
        ),
        DiagnosticButton(
          label: 'Clear email attribute',
          onPressed: () {
            bugseeManager.clearEmailAttribute();
          },
        ),
        DiagnosticButton(
          label: 'Clear name attribute',
          onPressed: () {
            bugseeManager.clearAttribute('name');
          },
        ),
        DiagnosticButton(
          label: 'Show report dialog',
          onPressed: () {
            bugseeManager.showCaptureLogReport();
          },
        ),
      ],
    );
  }
}
