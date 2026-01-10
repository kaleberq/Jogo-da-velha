import 'package:flutter/material.dart';
import 'package:jogo_da_velha/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
