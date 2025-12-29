import 'package:jogo_da_velha/data/services/enums/connection_status_enum.dart';

abstract class IGameRepository {
  // Callbacks
  Function(String)? get onMessageReceived;
  set onMessageReceived(Function(String)? callback);

  Function(String)? get onConnectionStatusChanged;
  set onConnectionStatusChanged(Function(String)? callback);

  Function(String)? get onError;
  set onError(Function(String)? callback);

  // Métodos de conexão
  Future<String?> getLocalIP();
  Future<String?> startServer({int port = 8080});
  Future<bool> connectToServer(String ip, {int port = 8080});
  void disconnect();

  // Métodos de jogo
  void sendMove(int row, int col, String player);
  void sendReset();
  void sendNextRound();
  void sendConfig(int maxRounds);

  // Status
  ConnectionStatusEnum get status;
}
