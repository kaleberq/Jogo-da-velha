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

  @override
  String get onlineOptionsTitle => 'Online Play';

  @override
  String get onlineOptionsChoose => 'Choose an option';

  @override
  String get createRoomTitle => 'Create a Room';

  @override
  String get createRoomDescription => 'Create a room for others to join';

  @override
  String get waitingPlayer => 'Waiting for a player to connect...';

  @override
  String get serverIpLabel => 'IP:';

  @override
  String get connectRoomTitle => 'Join a Room';

  @override
  String get serverIpInputLabel => 'Server IP';

  @override
  String get serverIpInputHint => 'e.g. 192.168.1.100';

  @override
  String get connectButton => 'Connect';

  @override
  String get errorCreateServer => 'Error creating server';

  @override
  String get errorEmptyIp => 'Please enter the server IP';

  @override
  String get errorConnectServer => 'Error connecting to server';
}
