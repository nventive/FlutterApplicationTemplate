import 'dart:io';

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

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forced Update Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'An update is required to continue using the application.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OutlinedButton(
              child: const Text('Update'),
              onPressed: () {
                _launchUrl();
              },
            ),
          ],
        ),
      ),
    );
  }
}
