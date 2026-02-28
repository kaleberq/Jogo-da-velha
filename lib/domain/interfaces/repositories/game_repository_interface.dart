import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';

/// Interface/abstração do Repository
abstract class IGameRepository {
  set onMessageReceived(Function(String)? callback);
  set onConnectionStatusChanged(Function(String)? callback);
  set onError(Function(String)? callback);

  Future<String?> startServer();
  Future<HostRoomModel> createHostRoom();
  Future<bool> connectToServer({required String ip});
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
