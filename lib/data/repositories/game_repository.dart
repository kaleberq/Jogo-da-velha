import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';

/// Implementação concreta do IGameRepository
/// Usa INetworkService para executar operações de rede
/// Constructor Injection: recebe dependência via construtor
class GameRepository implements IGameRepository {
  final INetworkService _networkService;

  /// Constructor Injection: INetworkService é obrigatório via construtor
  GameRepository({required INetworkService networkService})
    : _networkService = networkService;

  @override
  set onMessageReceived(Function(String)? callback) {
    _networkService.onMessageReceived = callback;
  }

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _networkService.onConnectionStatusChanged = callback;
  }

  @override
  set onError(Function(String)? callback) {
    _networkService.onError = callback;
  }

  @override
  Future<String?> startServer({int port = 8080}) async {
    return await _networkService.startServer(port: port);
  }

  @override
  Future<bool> connectToServer(String ip, {int port = 8080}) async {
    return await _networkService.connectToServer(ip, port: port);
  }

  @override
  void disconnect() {
    _networkService.disconnect();
  }

  @override
  void sendMove(int row, int col, String player) {
    _networkService.sendMove(row, col, player);
  }

  @override
  void sendReset() {
    _networkService.sendReset();
  }

  @override
  void sendNextRound() {
    _networkService.sendNextRound();
  }

  @override
  void sendConfig(int maxRounds) {
    _networkService.sendConfig(maxRounds);
  }
}
