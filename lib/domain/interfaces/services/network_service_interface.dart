import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';

abstract class INetworkService {
  set onMessageReceived(Function(String)? callback);
  set onConnectionStatusChanged(Function(String)? callback);
  set onError(Function(String)? callback);
  set onGameStateReceived(void Function(OnlineTicTacToeGameDTO)? callback);

  Future<String?> getLocalIP();
  Future<String?> startServer({required int port});
  Future<bool> connectToServer(String ip, {required int port});
  void disconnect();
  void sendReset();
  void sendNextRound();
  void sendConfig({required int maxRounds});
  void sendGameState(OnlineTicTacToeGameDTO dto);
  void sendRequestMove(int row, int col);
}
