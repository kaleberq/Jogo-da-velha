import 'package:jogo_da_velha/data/services/network_service.dart';

class GameRepository {
  final NetworkService _networkService = NetworkService();

  GameRepository();

  set onMessageReceived(Function(String)? callback) {
    _networkService.onMessageReceived = callback;
  }

  set onConnectionStatusChanged(Function(String)? callback) {
    _networkService.onConnectionStatusChanged = callback;
  }

  set onError(Function(String)? callback) {
    _networkService.onError = callback;
  }

  Future<String?> startServer({int port = 8080}) async {
    return await _networkService.startServer(port: port);
  }

  Future<bool> connectToServer(String ip, {int port = 8080}) async {
    return await _networkService.connectToServer(ip, port: port);
  }

  void disconnect() {
    _networkService.disconnect();
  }

  void sendMove(int row, int col, String player) {
    _networkService.sendMove(row, col, player);
  }

  void sendReset() {
    _networkService.sendReset();
  }

  void sendNextRound() {
    _networkService.sendNextRound();
  }

  void sendConfig(int maxRounds) {
    _networkService.sendConfig(maxRounds);
  }
}
