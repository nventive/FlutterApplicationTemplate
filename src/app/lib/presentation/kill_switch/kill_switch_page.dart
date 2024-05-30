import 'package:app/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';

final class KillSwitchPage extends StatelessWidget {
  const KillSwitchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final local = context.local;
    return Scaffold(
      key: const Key('KillSwitchScaffold'),
      appBar: AppBar(
        title: Text(local.killSwitchPageTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              local.killSwitchPageMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
