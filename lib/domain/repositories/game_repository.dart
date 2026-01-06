import 'package:jogo_da_velha/data/services/network_service.dart';
import 'package:jogo_da_velha/data/services/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/repositories/interfaces/game_repository_interface.dart';

class GameRepository implements IGameRepository {
  final NetworkService _networkService;
  NetworkConnectionManager? _connectionManager;

  // Callbacks - serão definidos pelo ViewModel
  Function(String)? _onMessageReceived;
  Function(String)? _onConnectionStatusChanged;
  Function(String)? _onError;

  // --- Singleton Setup ---
  static final GameRepository _instance = GameRepository._internal();

  factory GameRepository() {
    return _instance;
  }

  GameRepository._internal() : _networkService = NetworkService();
  // ----------------------

  @override
  Function(String)? get onMessageReceived => _onMessageReceived;

  @override
  set onMessageReceived(Function(String)? callback) {
    _onMessageReceived = callback;
  }

  @override
  Function(String)? get onConnectionStatusChanged => _onConnectionStatusChanged;

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _onConnectionStatusChanged = callback;
  }

  @override
  Function(String)? get onError => _onError;

  @override
  set onError(Function(String)? callback) {
    _onError = callback;
  }

  @override
  Future<String?> getLocalIP() => _networkService.getLocalIP();

  @override
  Future<String?> startServer({int port = 8080}) async {
    final ip = await _networkService.getLocalIP();
    _connectionManager = await _networkService.startServer(
      onStatusChanged: (status) {
        _onConnectionStatusChanged?.call(status.name);
      },
      onMessageReceived: (message) {
        _onMessageReceived?.call(message);
      },
      onError: (error) {
        _onError?.call(error);
      },
      port: port,
    );
    return ip;
  }

  @override
  Future<bool> connectToServer(String ip, {int port = 8080}) async {
    _connectionManager = await _networkService.connectToServer(
      ip: ip,
      onStatusChanged: (status) {
        _onConnectionStatusChanged?.call(status.name);
      },
      onMessageReceived: (message) {
        _onMessageReceived?.call(message);
      },
      onError: (error) {
        _onError?.call(error);
      },
      port: port,
    );
    return _connectionManager != null;
  }

  @override
  void disconnect() {
    _connectionManager?.disconnect();
    _connectionManager = null;
  }

  @override
  void sendMove(int row, int col, String player) {
    _connectionManager?.sendMove(row, col, player);
  }

  @override
  void sendReset() {
    _connectionManager?.sendReset();
  }

  @override
  void sendNextRound() {
    _connectionManager?.sendNextRound();
  }

  @override
  void sendConfig(int maxRounds) {
    _connectionManager?.sendConfig(maxRounds);
  }

  @override
  ConnectionStatusEnum get status {
    // O status agora é gerenciado pelo ViewModel através de callbacks
    // Este getter mantém compatibilidade mas não reflete o estado real
    return ConnectionStatusEnum.disconnected;
  }
}
