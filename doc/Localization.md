# Localization

We use [flutter_localization](https://pub.dev/packages/flutter_localization) for localization work.

For more documentation on localization, you can read [the official internationalization documentation for Flutter apps.](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

## Text localization

- We use `.arb` files located under the [arb folder](../lib/l10n/arb) to localize texts.

- We use an [extension](../src/app/lib/l10n/localization_extensions.dart) on `BuildContext` to resolve those localized texts.
 ``` dart
final local = context.local;

String myString = local.myString;
```

- The generated files are generated at [lib/l10n/gen_l10n](../src/app/lib/l10n/gen_l10n/) instead of the default location due to problems with the pipeline and artificial packages.

  > 💡 Please note that to be able to access the strings, you need to run `flutter pub get` to generate them.

- After running the app for the first time, localization files should be created automatically, if not it might be necessary to run the command `flutter gen-l10n` to generate the localization files.