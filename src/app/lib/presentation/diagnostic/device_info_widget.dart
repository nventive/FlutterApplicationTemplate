import 'dart:io';

import 'package:app/presentation/diagnostic/diagnostic_text.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A widget that displays device information.
final class DeviceInfoWidget extends StatelessWidget {
  const DeviceInfoWidget({super.key});

  Future<List<String>> getBuildAndAppInfo() async {
    var packageInfo = await PackageInfo.fromPlatform();
    var data = <String>[
      'Platform: ${Platform.operatingSystem}',
      'Operating System: ${Platform.operatingSystemVersion}',
      'Operating System Version: ${Platform.version}',
      'App Name: ${packageInfo.appName}',
      'Package Name: ${packageInfo.packageName}',
      'App Version: ${packageInfo.version}',
      'Build Number: ${packageInfo.buildNumber}',
    ];

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<String>>(
              future: getBuildAndAppInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DiagnosticText(text: 'Device Info'),
                      const Divider(),
                      for (var info in snapshot.data!)
                        DiagnosticText(text: info),
                    ],
                  );
                } else {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
