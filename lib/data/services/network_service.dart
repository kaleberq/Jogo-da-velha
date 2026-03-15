import 'dart:io';
import 'dart:convert';
import 'package:jogo_da_velha/data/datasources/network_connection_datasource.dart';
import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';
import 'package:jogo_da_velha/domain/enums/connection_message_enum.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_payload_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_type_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service que executa operações de rede.
/// Recebe/envia DTO e faz toJson/fromJson; não conhece modelo de domínio.
/// Usa [NetworkConnectionDatasource] (camada Data) para I/O de socket.
class NetworkService implements INetworkService {
  NetworkConnectionDatasource? _connectionDatasource;

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
    _updateConnectionDatasourceCallbacks();
  }

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _onConnectionStatusChanged = callback;
    _updateConnectionDatasourceCallbacks();
  }

  @override
  set onError(Function(String)? callback) {
    _onError = callback;
    _updateConnectionDatasourceCallbacks();
  }

  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameDTO)? callback) {
    _onGameStateReceived = callback;
  }

  void _updateConnectionDatasourceCallbacks() {
    if (_connectionDatasource != null) {
      _connectionDatasource!.onMessageReceived = _handleIncomingMessage;
      _connectionDatasource!.onStatusChanged = (status) {
        _onConnectionStatusChanged?.call(status.name);
      };
      _connectionDatasource!.onError = (error) {
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

  @override
  Future<String?> startServer({required int port}) async {
    try {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.connecting.name);
      final serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
      );

      _connectionDatasource = NetworkConnectionDatasource(
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
        _connectionDatasource!.setClientSocket(socket);
      });

      final ip = await getLocalIP();
      return ip;
    } catch (e) {
      _onConnectionStatusChanged?.call(ConnectionStatusEnum.error.name);
      _onError?.call('Erro ao criar servidor: $e');
      return null;
    }
  }

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

      _connectionDatasource = NetworkConnectionDatasource(
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
        _connectionDatasource?.sendMessage('CLIENT_CONNECTED');
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
    _connectionDatasource?.disconnect();
    _connectionDatasource = null;
  }

  @override
  void sendReset() {
    _connectionDatasource?.sendReset();
  }

  @override
  void sendNextRound() {
    _connectionDatasource?.sendNextRound();
  }

  @override
  void sendConfig({required int maxRounds}) {
    _connectionDatasource?.sendConfig(maxRounds);
  }

  @override
  void sendGameState(OnlineTicTacToeGameDTO dto) {
    _connectionDatasource?.sendGameState(dto.toJson());
  }

  @override
  void sendRequestMove(int row, int col) {
    _connectionDatasource?.sendRequestMove(row, col);
  }
}
