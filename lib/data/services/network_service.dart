import 'dart:io';
import 'dart:convert';
import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service que executa operações de rede
/// Singleton que mantém estado da conexão
class NetworkService implements INetworkService {
  NetworkConnectionManager? _connectionManager;

  // Callbacks - serão definidos pelo Repository
  Function(String)? _onMessageReceived;
  Function(String)? _onConnectionStatusChanged;
  Function(String)? _onError;

  // --- Singleton Setup ---
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal();
  // -----------------------

  // Configurar callbacks
  @override
  set onMessageReceived(Function(String)? callback) {
    _onMessageReceived = callback;
    _updateConnectionManagerCallbacks();
  }

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _onConnectionStatusChanged = callback;
    _updateConnectionManagerCallbacks();
  }

  @override
  set onError(Function(String)? callback) {
    _onError = callback;
    _updateConnectionManagerCallbacks();
  }

  void _updateConnectionManagerCallbacks() {
    if (_connectionManager != null) {
      _connectionManager!.onMessageReceived = (message) {
        _onMessageReceived?.call(message);
      };
      _connectionManager!.onStatusChanged = (status) {
        _onConnectionStatusChanged?.call(status.name);
      };
      _connectionManager!.onError = (error) {
        _onError?.call(error);
      };
    }
  }

  // Obter o IP local do dispositivo
  @override
  Future<String?> getLocalIP() async {
    try {
      final networkInfo = NetworkInfo();
      final wifiIP = await networkInfo.getWifiIP();
      return wifiIP;
    } catch (e) {
      return null;
    }
  }

  /// Cria um servidor e retorna o IP local
  @override
  Future<String?> startServer({required int port}) async {
    try {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.connecting.name);
      final serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
      );

      _connectionManager = NetworkConnectionManager(
        serverSocket: serverSocket,
        onStatusChanged: (status) {
          _onConnectionStatusChanged?.call(status.name);
        },
        onMessageReceived: (message) {
          _onMessageReceived?.call(message);
        },
        onError: (error) {
          _onError?.call(error);
        },
      );

      serverSocket.listen((Socket socket) {
        _connectionManager!.setClientSocket(socket);
      });

      final ip = await getLocalIP();
      return ip;
    } catch (e) {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.error.name);
      _onError?.call('Erro ao criar servidor: $e');
      return null;
    }
  }

  /// Conecta a um servidor
  @override
  Future<bool> connectToServer(String ip, {required int port}) async {
    try {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.connecting.name);
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 10),
      );

      socket.setOption(SocketOption.tcpNoDelay, true);
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.connected.name);

      _connectionManager = NetworkConnectionManager(
        clientSocket: socket,
        onStatusChanged: (status) {
          _onConnectionStatusChanged?.call(status.name);
        },
        onMessageReceived: (message) {
          _onMessageReceived?.call(message);
        },
        onError: (error) {
          _onError?.call(error);
        },
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        _connectionManager?.sendMessage('CLIENT_CONNECTED');
      });

      return true;
    } catch (e) {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.error.name);
      _onError?.call('Erro ao conectar: $e');
      return false;
    }
  }

  @override
  void disconnect() {
    _connectionManager?.disconnect();
    _connectionManager = null;
  }

  @override
  void sendMove({
    required int row,
    required int col,
    required PlayerEnum player,
  }) {
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
  void sendConfig({required int maxRounds}) {
    _connectionManager?.sendConfig(maxRounds);
  }

  @override
  void sendGameState(Map<String, dynamic> state) {
    _connectionManager?.sendGameState(state);
  }

  @override
  void sendRequestMove(int row, int col) {
    _connectionManager?.sendRequestMove(row, col);
  }
}

/// Gerencia uma conexão de rede ativa
/// Mantém os recursos (sockets) mas o estado é notificado via callbacks
class NetworkConnectionManager {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  String _buffer = '';
  Function(ConnectionStatusEnum) onStatusChanged;
  Function(String) onMessageReceived;
  Function(String) onError;

  NetworkConnectionManager({
    ServerSocket? serverSocket,
    Socket? clientSocket,
    required this.onStatusChanged,
    required this.onMessageReceived,
    required this.onError,
  }) : _serverSocket = serverSocket,
       _clientSocket = clientSocket {
    if (_clientSocket != null) {
      _listenToClient(_clientSocket!);
    }
  }

  void setClientSocket(Socket socket) {
    if (_clientSocket != null) {
      try {
        _clientSocket!.destroy();
      } catch (e) {
        // Ignora erros
      }
    }

    socket.setOption(SocketOption.tcpNoDelay, true);
    _clientSocket = socket;
    onStatusChanged(ConnectionStatusEnum.connected);
    _listenToClient(socket);

    Future.microtask(() {
      try {
        socket.add(utf8.encode('SERVER_CONNECTED\n'));
      } catch (e) {
        onError('Erro ao confirmar conexão: $e');
      }
    });
    onMessageReceived(NetworkMessageConstants.peerConnected);
  }

  void _listenToClient(Socket socket) {
    socket.listen(
      (data) {
        _buffer += utf8.decode(data);
        final lines = _buffer.split('\n');
        _buffer = lines.removeLast();

        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            onMessageReceived(line.trim());
          }
        }
      },
      onError: (error) {
        onStatusChanged(ConnectionStatusEnum.error);
        onError('Erro na conexão: $error');
      },
      onDone: () {
        onStatusChanged(ConnectionStatusEnum.disconnected);
        _buffer = '';
        onMessageReceived('DISCONNECTED');
      },
      cancelOnError: false,
    );
  }

  void sendMessage(String message) {
    if (_clientSocket != null) {
      try {
        _clientSocket!.add(utf8.encode('$message\n'));
      } catch (e) {
        onStatusChanged(ConnectionStatusEnum.error);
        onError('Erro ao enviar mensagem: $e');
      }
    }
  }

  void sendMove(int row, int col, PlayerEnum player) {
    final data = jsonEncode({
      'type': 'move',
      'row': row,
      'col': col,
      'player':
          player.name, // Converte enum para String (retorna "x", "o" ou "none")
    });
    sendMessage(data);
  }

  void sendGameState(Map<String, dynamic> state) {
    final data = jsonEncode({
      'type': 'gameState',
      ...state,
    });
    sendMessage(data);
  }

  void sendRequestMove(int row, int col) {
    final data = jsonEncode({
      'type': 'requestMove',
      'row': row,
      'col': col,
    });
    sendMessage(data);
  }

  void sendReset() {
    final data = jsonEncode({'type': 'reset'});
    sendMessage(data);
  }

  void sendNextRound() {
    final data = jsonEncode({'type': 'nextRound'});
    sendMessage(data);
  }

  void sendConfig(int maxRounds) {
    final data = jsonEncode({'type': 'config', 'maxRounds': maxRounds});
    sendMessage(data);
  }

  void disconnect() {
    try {
      _clientSocket?.destroy();
      _serverSocket?.close();
    } catch (e) {
      // Ignora erros
    }
    _clientSocket = null;
    _serverSocket = null;
    _buffer = '';
    onStatusChanged(ConnectionStatusEnum.disconnected);
  }
}
