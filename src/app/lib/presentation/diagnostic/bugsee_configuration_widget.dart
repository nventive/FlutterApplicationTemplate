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
    isConfigEnabled = bugseeManager.isBugseeEnabled;
    isCaptureVideoEnabled = bugseeManager.isVideoCaptureEnabled;
    requireRestart = bugseeManager.isRestartRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            if (!bugseeManager.isConfigurationValid)
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
                  "In order to reactivate Bugsee logger restart the app.",
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
                await bugseeManager.setIsBugseeEnabled(value);
                setState(() {
                  isConfigEnabled = bugseeManager.isBugseeEnabled;
                  isCaptureVideoEnabled = bugseeManager.isVideoCaptureEnabled;
                  requireRestart = bugseeManager.isRestartRequired;
                });
              },
            ),
            DiagnosticSwitch(
              label: 'Video capture enabled',
              value: isCaptureVideoEnabled,
              onChanged: (value) async {
                await bugseeManager.setIsVideoCaptureEnabled(value);
                setState(() {
                  isCaptureVideoEnabled = bugseeManager.isVideoCaptureEnabled;
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
          label: 'Log an unhandled exception',
          onPressed: () {
            bugseeManager.logUnhandledException(exception: Exception());
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
