import 'dart:io';
import 'dart:convert';
import 'package:jogo_da_velha/data/services/enums/connection_status_enum.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service que executa operações de rede
/// Mantém recursos de conexão (sockets) mas delega estado para callbacks
class NetworkService {
  NetworkService();

  // Obter o IP local do dispositivo
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
  /// Retorna um NetworkConnectionManager que gerencia a conexão
  Future<NetworkConnectionManager?> startServer({
    required Function(ConnectionStatusEnum) onStatusChanged,
    required Function(String) onMessageReceived,
    required Function(String) onError,
    int port = 8080,
  }) async {
    try {
      onStatusChanged(ConnectionStatusEnum.connecting);
      final serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
      );

      final connectionManager = NetworkConnectionManager(
        serverSocket: serverSocket,
        onStatusChanged: onStatusChanged,
        onMessageReceived: onMessageReceived,
        onError: onError,
      );

      serverSocket.listen((Socket socket) {
        connectionManager.setClientSocket(socket);
      });

      await getLocalIP();
      return connectionManager;
    } catch (e) {
      onStatusChanged(ConnectionStatusEnum.error);
      onError('Erro ao criar servidor: $e');
      return null;
    }
  }

  /// Conecta a um servidor
  /// Retorna um NetworkConnectionManager que gerencia a conexão
  Future<NetworkConnectionManager?> connectToServer({
    required String ip,
    required Function(ConnectionStatusEnum) onStatusChanged,
    required Function(String) onMessageReceived,
    required Function(String) onError,
    int port = 8080,
  }) async {
    try {
      onStatusChanged(ConnectionStatusEnum.connecting);
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 10),
      );

      socket.setOption(SocketOption.tcpNoDelay, true);
      onStatusChanged(ConnectionStatusEnum.connected);

      final connectionManager = NetworkConnectionManager(
        clientSocket: socket,
        onStatusChanged: onStatusChanged,
        onMessageReceived: onMessageReceived,
        onError: onError,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        connectionManager.sendMessage('CLIENT_CONNECTED');
      });

      return connectionManager;
    } catch (e) {
      onStatusChanged(ConnectionStatusEnum.error);
      onError('Erro ao conectar: $e');
      return null;
    }
  }
}

/// Gerencia uma conexão de rede ativa
/// Mantém os recursos (sockets) mas o estado é notificado via callbacks
class NetworkConnectionManager {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  String _buffer = '';
  final Function(ConnectionStatusEnum) onStatusChanged;
  final Function(String) onMessageReceived;
  final Function(String) onError;

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
    onMessageReceived('CONNECTED');
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

  void sendMove(int row, int col, String player) {
    final data = jsonEncode({
      'type': 'move',
      'row': row,
      'col': col,
      'player': player,
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
