// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tic Tac Toe';

  @override
  String get menuTitle => 'Menu';

  @override
  String get chooseGameMode => 'Choose a game mode.';

  @override
  String get localModeTitle => 'Local Mode';

  @override
  String get localModeDescription => 'Play on the same device';

  @override
  String get onlineModeTitle => 'Online Play';

  @override
  String get onlineModeDescription => 'Play with another player online';
}
