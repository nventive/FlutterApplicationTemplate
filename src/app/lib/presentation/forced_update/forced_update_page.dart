import 'dart:io';

import 'package:app/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

final class ForcedUpdatePage extends StatelessWidget {
  ForcedUpdatePage({super.key}) {
    if (Platform.isIOS) {
      _url = Uri.parse(dotenv.env['APP_STORE_URL_IOS']!);
    } else {
      _url = Uri.parse(dotenv.env['APP_STORE_URL_Android']!);
    }
  }

  late final Uri _url;

  Future<void> _launchUrl(BuildContext context) async {
    // We get the error message from the localization file first to avoid
    // using the context after an asynchronous operation.
    var errorMessage = context.local.forcedUpdatePageUrlLaunchException(_url);
    if (!await launchUrl(_url)) {
      throw Exception(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = context.local;
    return Scaffold(
      key: const Key('forcedUpdateScaffold'),
      appBar: AppBar(
        title: Text(local.forcedUpdatePageTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              local.forcedUpdatePageUpdateRequiredMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OutlinedButton(
              child: Text(local.forcedUpdatePageUpdateButton),
              onPressed: () {
                _launchUrl(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
