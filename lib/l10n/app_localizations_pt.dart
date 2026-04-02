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
  String get localModeTitle => 'Jogo Local';

  @override
  String get localModeDescription => 'Jogue no mesmo dispositivo com outro jogador.';

  @override
  String get onlineModeTitle => 'Jogo Online';

  @override
  String get onlineModeDescription => 'Jogue com outro jogador online, cada um em seu dispositivo.';

  @override
  String get onlineOptionsTitle => 'Jogar Online';

  @override
  String get createRoomTitle => 'Criar uma Sala';

  @override
  String get createRoomDescription => 'Crie uma sala para que outro jogador se conecte.';

  @override
  String get waitingPlayer => 'Aguardando jogador se conectar...';

  @override
  String get serverIpLabel => 'IP:';

  @override
  String get connectRoomTitle => 'Conectar a uma Sala';

  @override
  String get serverIpInputLabel => 'IP do Servidor';

  @override
  String get serverIpInputHint => 'Ex: 192.168.1.100';

  @override
  String get connectButton => 'Conectar';

  @override
  String get errorCreateServer => 'Erro ao criar servidor';

  @override
  String get errorEmptyIp => 'Por favor, insira o IP do servidor';

  @override
  String get errorConnectServer => 'Erro ao conectar ao servidor';

  @override
  String get gameEndTitle => 'Fim de Jogo';

  @override
  String get finalScore => 'Placar Final';

  @override
  String get playAgain => 'Jogar Novamente';

  @override
  String get nextRound => 'Próxima Rodada';

  @override
  String get playerXWonGame => 'Jogador X venceu o jogo!';

  @override
  String get playerOWonGame => 'Jogador O venceu o jogo!';

  @override
  String get tieGame => 'Empate! Ninguém venceu.';

  @override
  String playerWonRound(String player) {
    return 'Jogador $player venceu esta rodada!';
  }

  @override
  String get drawRound => 'Deu Velha';

  @override
  String get settings => 'Configurações';

  @override
  String get numberOfRounds => 'Número de Rodadas';

  @override
  String get chooseRoundsRange => 'Escolha entre 1 e 20 rodadas';

  @override
  String get apply => 'Aplicar';

  @override
  String get resetAll => 'Reiniciar Tudo';

  @override
  String get yourTurn => 'Sua vez de jogar';

  @override
  String get waiting => 'Vez do adversário';

  @override
  String get waitYourTurn => 'Aguarde sua vez!';

  @override
  String get finalScoreLabel => 'Placar Final:';

  @override
  String playerXScore(int score) {
    return 'Jogador X: $score';
  }

  @override
  String playerOScore(int score) {
    return 'Jogador O: $score';
  }

  @override
  String get connectionLost => 'Conexão Perdida';

  @override
  String get connectionLostMessage => 'A conexão com o outro jogador foi perdida.';

  @override
  String get backToMenu => 'Voltar ao Menu';

  @override
  String get roundText => 'Rodada';

  @override
  String get timeLimit => 'Tempo Limite';

  @override
  String get timeLimitSeconds => 'Tempo Limite (segundos)';

  @override
  String get chooseTimeLimitRange => 'Escolha entre 10 e 60 segundos';

  @override
  String get scanQrCodeToConnect => 'Escaneie o QR Code para conectar';

  @override
  String get scanQrCode => 'Escanear QR Code';

  @override
  String get openingScanner => 'Abrindo scanner...';
}
