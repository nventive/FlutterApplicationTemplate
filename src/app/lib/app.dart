import 'package:app/app_router.dart';
import 'package:app/l10n/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
