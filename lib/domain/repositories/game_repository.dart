import 'package:jogo_da_velha/data/services/network_service.dart';

class GameRepository {
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

  set onMessageReceived(Function(String)? callback) {
    _onMessageReceived = callback;
  }

  set onConnectionStatusChanged(Function(String)? callback) {
    _onConnectionStatusChanged = callback;
  }

  set onError(Function(String)? callback) {
    _onError = callback;
  }

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

  void disconnect() {
    _connectionManager?.disconnect();
    _connectionManager = null;
  }

  void sendMove(int row, int col, String player) {
    _connectionManager?.sendMove(row, col, player);
  }

  void sendReset() {
    _connectionManager?.sendReset();
  }

  void sendNextRound() {
    _connectionManager?.sendNextRound();
  }
}
