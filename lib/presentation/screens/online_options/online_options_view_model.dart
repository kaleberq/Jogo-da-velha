import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/domain/repositories/game_repository.dart';

class OnlineOptionsViewModel extends ChangeNotifier {
  final GameRepository _gameRepository = GameRepository();
  bool _isCreatingServer = false;
  bool _isConnecting = false;
  String? _serverIP;
  bool _navigatingToGame = false;

  bool get isCreatingServer => _isCreatingServer;
  bool get isConnecting => _isConnecting;
  String? get serverIP => _serverIP;
  bool get navigatingToGame => _navigatingToGame;

  OnlineOptionsViewModel() {
    _setupNetworkCallbacks();
  }

  void _setupNetworkCallbacks() {
    _gameRepository.onMessageReceived = (message) {
      // Quando recebe CONNECTED e é servidor (tem IP), navega para o jogo
      if (message == 'CONNECTED' && _serverIP != null && !_navigatingToGame) {
        _navigatingToGame = true;
        notifyListeners();
      }
    };

    _gameRepository.onError = (error) {
      _isCreatingServer = false;
      _isConnecting = false;
      notifyListeners();
      onError?.call(error);
    };
  }

  // Callback para erros - será definido pela UI
  Function(String)? onError;

  Future<String?> createServer() async {
    _isCreatingServer = true;
    notifyListeners();

    final ip = await _gameRepository.startServer();
    if (ip != null) {
      _serverIP = ip;
      _isCreatingServer = false;
      notifyListeners();
      return ip;
    } else {
      _isCreatingServer = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> connectToServer(String ip) async {
    _isConnecting = true;
    notifyListeners();

    final connected = await _gameRepository.connectToServer(ip);
    if (connected) {
      _navigatingToGame = true;
      _isConnecting = false;
      notifyListeners();
      return true;
    } else {
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void resetServerState() {
    _isCreatingServer = false;
    _serverIP = null;
    notifyListeners();
  }

  void resetConnectionState() {
    _isConnecting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (!_navigatingToGame) {
      _gameRepository.disconnect();
    }
    super.dispose();
  }
}
