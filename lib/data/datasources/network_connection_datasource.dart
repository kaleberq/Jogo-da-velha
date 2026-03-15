import 'dart:io';
import 'dart:convert';

import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';
import 'package:jogo_da_velha/domain/enums/connection_message_enum.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/config_data_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_payload_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_type_enum.dart';
import 'package:jogo_da_velha/domain/enums/request_move_data_key_enum.dart';

/// Data source que gerencia uma conexão de rede ativa (socket).
/// Responsável por: buffer de leitura (linhas), envio de mensagens, formato do protocolo.
/// Fica na camada Data (Clean Architecture) como fonte de dados remota.
class NetworkConnectionDatasource {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  String _buffer = '';
  Function(ConnectionStatusEnum) onStatusChanged;
  Function(String) onMessageReceived;
  Function(String) onError;

  NetworkConnectionDatasource({
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
