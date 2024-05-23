import 'package:app/l10n/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationExtensions on BuildContext {
  AppLocalizations get local => AppLocalizations.of(this);
}
