import 'package:jogo_da_velha/data/services/network_service.dart';
import 'package:jogo_da_velha/data/services/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';

class GameRepository implements IGameRepository {
  final NetworkService _networkService;

  GameRepository() : _networkService = NetworkService();

  @override
  Function(String)? get onMessageReceived => _networkService.onMessageReceived;

  @override
  set onMessageReceived(Function(String)? callback) {
    _networkService.onMessageReceived = callback;
  }

  @override
  Function(String)? get onConnectionStatusChanged =>
      _networkService.onConnectionStatusChanged;

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _networkService.onConnectionStatusChanged = callback;
  }

  @override
  Function(String)? get onError => _networkService.onError;

  @override
  set onError(Function(String)? callback) {
    _networkService.onError = callback;
  }

  @override
  Future<String?> getLocalIP() => _networkService.getLocalIP();

  @override
  Future<String?> startServer({int port = 8080}) =>
      _networkService.startServer(port: port);

  @override
  Future<bool> connectToServer(String ip, {int port = 8080}) =>
      _networkService.connectToServer(ip, port: port);

  @override
  void disconnect() => _networkService.disconnect();

  @override
  void sendMove(int row, int col, String player) =>
      _networkService.sendMove(row, col, player);

  @override
  void sendReset() => _networkService.sendReset();

  @override
  void sendNextRound() => _networkService.sendNextRound();

  @override
  void sendConfig(int maxRounds) => _networkService.sendConfig(maxRounds);

  @override
  ConnectionStatusEnum get status => _networkService.status;
}
