import 'package:app/business/bugsee/bugsee_manager.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/diagnostic_switch.dart';
import 'package:flutter/foundation.dart';
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

  late bool isConfigEnabled;
  late bool isCaptureVideoEnabled;
  late bool requireRestart;

  @override
  void initState() {
    super.initState();
    isConfigEnabled = bugseeManager.bugseeIsEnabled;
    isCaptureVideoEnabled = bugseeManager.captureVideoIsEnabled;
    requireRestart = bugseeManager.configurationHasChanged;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            if (!bugseeManager.isValidConfiguration)
              Container(
                color: const Color.fromARGB(170, 255, 0, 0),
                child: const Text(
                  kDebugMode
                      ? "Bugsee is disabled in debug mode."
                      : "Invalid Bugsee token, capturing exceptions could not start",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            if (requireRestart)
              Container(
                color: const Color.fromARGB(170, 255, 0, 0),
                child: const Text(
                  "Bugsee config has changed please restart the app.",
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
              value: isConfigEnabled,
              onChanged: (value) async {
                bugseeManager.updateBugseeEnabledValue(value);
                setState(() {
                  isConfigEnabled = bugseeManager.bugseeIsEnabled;
                  isCaptureVideoEnabled = bugseeManager.captureVideoIsEnabled;
                  requireRestart = bugseeManager.configurationHasChanged;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Video capture enabled',
              value: isCaptureVideoEnabled,
              onChanged: (value) async {
                bugseeManager.updateIsVideoCuptureValue(value);
                setState(() {
                  isCaptureVideoEnabled = bugseeManager.captureVideoIsEnabled;
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
          label: 'Show report dialog',
          onPressed: () {
            bugseeManager.showCaptureLogReport();
          },
        ),
      ],
    );
  }
}
