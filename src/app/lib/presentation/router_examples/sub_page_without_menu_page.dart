import 'package:app/app_router.dart';
import 'package:flutter/material.dart';

final class SubPageWithoutMenuPage extends StatelessWidget {
  const SubPageWithoutMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This is a sub page without a menu',
            ),
            ElevatedButton(
              child: const Text('Return to the setting page'),
              onPressed: () {
                router.go(settingPagePath);
              },
            ),
            ElevatedButton(
              child: const Text('Go to SubPageWithMenu'),
              onPressed: () {
                router.go('$settingPagePath/$subPageWithMenuPath');
              },
            ),
            ElevatedButton(
              child: const Text(
                'Go to to the dad jokes page',
              ),
              onPressed: () {
                router.go(dadJokesPagePath);
              },
            ),
          ],
        ),
      ),
    );
  }
}
