// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Jogo da Velha';

  @override
  String get menuTitle => 'Menu';

  @override
  String get chooseGameMode => 'Escolha um modo de jogo';

  @override
  String get localModeTitle => 'Modo Local';

  @override
  String get localModeDescription => 'Jogue no mesmo dispositivo';

  @override
  String get onlineModeTitle => 'Jogar Online';

  @override
  String get onlineModeDescription => 'Jogue com outro jogador online';
}
