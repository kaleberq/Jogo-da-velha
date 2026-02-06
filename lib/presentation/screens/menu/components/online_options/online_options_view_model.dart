import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/channels/qr_code_generate.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/models/online_options_model.dart';

/// ViewModel para tela de opções online
/// Constructor Injection: recebe IGameRepository via construtor
class OnlineOptionsViewModel extends ChangeNotifier {
  final IGameRepository _gameRepository;
  final OnlineOptionsModel _onlineOptions = OnlineOptionsModel();

  /// Constructor Injection: IGameRepository é obrigatório via construtor
  OnlineOptionsViewModel({required IGameRepository gameRepository})
    : _gameRepository = gameRepository {
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
    final Uint8List qrBytes = await NativeQrGenerator.generate(
      '123.234.563.10',
    );

    print('aaa-> ${qrBytes.length}');

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
