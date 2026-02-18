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
  String get localModeTitle => 'Local game';

  @override
  String get localModeDescription => 'Play on the same device with another player.';

  @override
  String get onlineModeTitle => 'Online Play';

  @override
  String get onlineModeDescription => 'Play with another player online, each on their own device.';

  @override
  String get onlineOptionsTitle => 'Online Play';

  @override
  String get createRoomTitle => 'Create a Room';

  @override
  String get createRoomDescription => 'Create a room so that another player can connect.';

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

  @override
  String get gameEndTitle => 'Game Over';

  @override
  String get finalScore => 'Final Score';

  @override
  String get playAgain => 'Play Again';

  @override
  String get nextRound => 'Next Round';

  @override
  String get playerXWonGame => 'Player X won the game!';

  @override
  String get playerOWonGame => 'Player O won the game!';

  @override
  String get tieGame => 'Tie! No one won.';

  @override
  String playerWonRound(String player) {
    return 'Player $player won this round!';
  }

  @override
  String get drawRound => 'Draw';

  @override
  String get settings => 'Settings';

  @override
  String get numberOfRounds => 'Number of Rounds';

  @override
  String get chooseRoundsRange => 'Choose between 1 and 20 rounds';

  @override
  String get apply => 'Apply';

  @override
  String get resetAll => 'Reset All';

  @override
  String get yourTurn => 'Your Turn';

  @override
  String get waiting => 'Waiting...';

  @override
  String get waitYourTurn => 'Wait your turn!';

  @override
  String get finalScoreLabel => 'Final Score:';

  @override
  String playerXScore(int score) {
    return 'Player X: $score';
  }

  @override
  String playerOScore(int score) {
    return 'Player O: $score';
  }

  @override
  String get connectionLost => 'Connection Lost';

  @override
  String get connectionLostMessage => 'The connection with the other player was lost.';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get roundText => 'Round';

  @override
  String get timeLimit => 'Time Limit';

  @override
  String get timeLimitSeconds => 'Time Limit (seconds)';

  @override
  String get chooseTimeLimitRange => 'Choose between 10 and 60 seconds';

  @override
  String get scanQrCodeToConnect => 'Scan the QR Code to connect';

  @override
  String get connecting => 'Connecting...';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get openingScanner => 'Opening scanner...';
}
