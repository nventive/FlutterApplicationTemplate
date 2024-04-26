import 'package:app/app_router.dart';
import 'package:flutter/material.dart';

final class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Go to SubPageWithMenu'),
              onPressed: () {
                router.go('$settingPagePath/$subPageWithMenuPath');
              },
            ),
            ElevatedButton(
              child: const Text('Go to SubPageWithoutMenu'),
              onPressed: () {
                router.push(subPageWithoutMenuPath);
              },
            ),
            ElevatedButton(
              child: const Text(
                'Go to SubPageWithoutMenu without back navigation',
              ),
              onPressed: () {
                router.go(subPageWithoutMenuPath);
              },
            ),
          ],
        ),
      ),
    );
  }
}
