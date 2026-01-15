import 'package:jogo_da_velha/domain/enums/player_enum.dart';

/// Interface/abstração do Repository
/// Define o contrato para operações de rede do jogo
/// Domain não depende de Data - apenas define o contrato
abstract class IGameRepository {
  set onMessageReceived(Function(String)? callback);
  set onConnectionStatusChanged(Function(String)? callback);
  set onError(Function(String)? callback);

  Future<String?> startServer({int port = 8080});
  Future<bool> connectToServer(String ip, {int port = 8080});
  void disconnect();
  void sendMove(int row, int col, PlayerEnum player);
  void sendReset();
  void sendNextRound();
  void sendConfig(int maxRounds);
}
