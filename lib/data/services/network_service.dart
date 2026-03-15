import 'dart:io';
import 'dart:convert';
import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';
import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';
import 'package:jogo_da_velha/domain/enums/connection_message_enum.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/config_data_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_payload_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_type_enum.dart';
import 'package:jogo_da_velha/domain/enums/request_move_data_key_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service que executa operações de rede.
/// Recebe/envia DTO e faz toJson/fromJson; não conhece modelo de domínio.
class NetworkService implements INetworkService {
  NetworkConnectionManager? _connectionManager;

  Function(String)? _onMessageReceived;
  Function(String)? _onConnectionStatusChanged;
  Function(String)? _onError;
  void Function(OnlineTicTacToeGameDTO)? _onGameStateReceived;

  // --- Singleton Setup ---
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal();
  // -----------------------

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

  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameDTO)? callback) {
    _onGameStateReceived = callback;
  }

  void _updateConnectionManagerCallbacks() {
    if (_connectionManager != null) {
      _connectionManager!.onMessageReceived = _handleIncomingMessage;
      _connectionManager!.onStatusChanged = (status) {
        _onConnectionStatusChanged?.call(status.name);
      };
      _connectionManager!.onError = (error) {
        _onError?.call(error);
      };
    }
  }

  void _handleIncomingMessage(String message) {
    if (ConnectionMessageEnum.tryParse(message) != null) {
      _onMessageReceived?.call(message);
      return;
    }
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final typeStr = data[GameMessagePayloadKeyEnum.type.key] as String?;
      final type = GameMessageTypeEnum.tryParse(typeStr);

      if (type == GameMessageTypeEnum.gameState) {
        final dto = OnlineTicTacToeGameDTO.fromJson(
          Map<String, dynamic>.from(data),
        );
        _onGameStateReceived?.call(dto);
      } else {
        _onMessageReceived?.call(message);
      }
    } catch (_) {
      _onMessageReceived?.call(message);
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
        onMessageReceived: _handleIncomingMessage,
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
        onMessageReceived: _handleIncomingMessage,
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
  void sendGameState(OnlineTicTacToeGameDTO dto) {
    _connectionManager?.sendGameState(dto.toJson());
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
        onMessageReceived(ConnectionMessageEnum.disconnected.value);
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

  void sendGameState(Map<String, dynamic> state) {
    final data = jsonEncode({
      GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.gameState.value,
      ...state,
    });
    sendMessage(data);
  }

  void sendRequestMove(int row, int col) {
    final data = jsonEncode({
      GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.requestMove.value,
      RequestMoveDataKeyEnum.row.key: row,
      RequestMoveDataKeyEnum.col.key: col,
    });
    sendMessage(data);
  }

  void sendReset() {
    final data = jsonEncode({
      GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.reset.value,
    });
    sendMessage(data);
  }

  void sendNextRound() {
    final data = jsonEncode({
      GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.nextRound.value,
    });
    sendMessage(data);
  }

  void sendConfig(int maxRounds) {
    final data = jsonEncode({
      GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.config.value,
      ConfigDataKeyEnum.maxRounds.key: maxRounds,
    });
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
