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

  @override
  String get onlineOptionsTitle => 'Jogar Online';

  @override
  String get onlineOptionsChoose => 'Escolha uma opção';

  @override
  String get createRoomTitle => 'Criar uma Sala';

  @override
  String get createRoomDescription => 'Criar uma sala para outros se conectarem';

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
}
