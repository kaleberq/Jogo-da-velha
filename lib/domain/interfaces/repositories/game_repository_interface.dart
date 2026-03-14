import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';

/// Interface/abstração do Repository
abstract class IGameRepository {
  set onMessageReceived(Function(String)? callback);
  set onConnectionStatusChanged(Function(String)? callback);
  set onError(Function(String)? callback);
  set onGameStateReceived(void Function(OnlineTicTacToeGameModel)? callback);
  set onRequestMove(void Function(int row, int col)? callback);
  set onResetReceived(void Function()? callback);
  set onNextRoundReceived(void Function()? callback);
  set onConfigReceived(void Function(int maxRounds)? callback);

  Future<String?> startServer();
  Future<HostRoomModel> createHostRoom();
  Future<bool> connectToServer({required String ip});
  void disconnect();
  void sendReset();
  void sendNextRound();
  void sendConfig({required int maxRounds});
  void sendRequestMove(int row, int col);
  void sendGameState(Map<String, dynamic> state);
  void sendCurrentGameState(OnlineTicTacToeGameModel game);
}
