import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/domain/models/online_options_model.dart';
import 'package:jogo_da_velha/domain/repositories/game_repository.dart';
import 'package:jogo_da_velha/domain/interfaces/game_repository_interface.dart';

class OnlineOptionsViewModel extends ChangeNotifier {
  final IGameRepository _gameRepository = GameRepository();
  final OnlineOptionsModel _onlineOptions = OnlineOptionsModel();

  OnlineOptionsViewModel() {
    _setupNetworkCallbacks();
  }

  OnlineOptionsModel get onlineOptions => _onlineOptions;

  void _setupNetworkCallbacks() {
    _gameRepository.onMessageReceived = (message) {
      // Quando recebe CONNECTED e é servidor (tem IP), navega para o jogo
      if (message == 'CONNECTED' &&
          _onlineOptions.serverIP != null &&
          !_onlineOptions.navigatingToGame) {
        _onlineOptions.navigatingToGame = true;
        notifyListeners();
      }
    };

    _gameRepository.onError = (error) {
      _onlineOptions.isCreatingServer = false;
      _onlineOptions.isConnecting = false;
      notifyListeners();
      onError?.call(error);
    };
  }

  // Callback para erros - será definido pela UI
  Function(String)? onError;

  Future<String?> createServer() async {
    _onlineOptions.isCreatingServer = true;
    notifyListeners();

    final ip = await _gameRepository.startServer();
    if (ip != null) {
      _onlineOptions.serverIP = ip;
      _onlineOptions.isCreatingServer = false;
      notifyListeners();
      return ip;
    } else {
      _onlineOptions.isCreatingServer = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> connectToServer(String ip) async {
    _onlineOptions.isConnecting = true;
    notifyListeners();

    final connected = await _gameRepository.connectToServer(ip);
    if (connected) {
      _onlineOptions.navigatingToGame = true;
      _onlineOptions.isConnecting = false;
      notifyListeners();
      return true;
    } else {
      _onlineOptions.isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  void resetServerState() {
    _onlineOptions.resetServerState();
    notifyListeners();
  }

  void resetConnectionState() {
    _onlineOptions.resetConnectionState();
    notifyListeners();
  }

  @override
  void dispose() {
    if (!_onlineOptions.navigatingToGame) {
      _gameRepository.disconnect();
    }
    super.dispose();
  }
}
