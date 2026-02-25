import 'package:jogo_da_velha/domain/enums/player_enum.dart';

/// Interface/abstração do NetworkService
/// Define o contrato para operações de rede
/// Domain não depende de Data - apenas define o contrato
abstract class INetworkService {
  set onMessageReceived(Function(String)? callback);
  set onConnectionStatusChanged(Function(String)? callback);
  set onError(Function(String)? callback);

  Future<String?> getLocalIP();
  Future<String?> startServer({required int port});
  Future<bool> connectToServer(String ip, {required int port});
  void disconnect();
  void sendMove({
    required int row,
    required int col,
    required PlayerEnum player,
  });
  void sendReset();
  void sendNextRound();
  void sendConfig({required int maxRounds});
}
