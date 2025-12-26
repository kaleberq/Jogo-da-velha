import 'dart:io';
import 'dart:convert';
import 'package:jogo_da_velha/data/network/enums/connection_status_enum.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkService {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  ConnectionStatusEnum _status = ConnectionStatusEnum.disconnected;
  Function(String)? onMessageReceived;
  Function(String)? onConnectionStatusChanged;
  Function(String)? onError;
  String _buffer = '';

  ConnectionStatusEnum get status => _status;

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

  // Criar servidor (host)
  Future<String?> startServer({int port = 8080}) async {
    try {
      _updateStatus(ConnectionStatusEnum.connecting);
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);

      _serverSocket!.listen((Socket socket) {
        if (_clientSocket != null) {
          // Fecha conexão anterior se houver
          try {
            _clientSocket!.destroy();
          } catch (e) {
            // Ignora erros
          }
        }

        // Configura opções do socket para melhor performance
        socket.setOption(SocketOption.tcpNoDelay, true);

        _clientSocket = socket;
        _updateStatus(ConnectionStatusEnum.connected);
        _listenToClient(socket);

        // Envia mensagem de confirmação para o cliente
        Future.microtask(() {
          try {
            socket.add(utf8.encode('SERVER_CONNECTED\n'));
          } catch (e) {
            onError?.call('Erro ao confirmar conexão: $e');
          }
        });
        onMessageReceived?.call('CONNECTED');
      });

      final ip = await getLocalIP();
      return ip;
    } catch (e) {
      _updateStatus(ConnectionStatusEnum.error);
      onError?.call('Erro ao criar servidor: $e');
      return null;
    }
  }

  // Conectar a um servidor (cliente)
  Future<bool> connectToServer(String ip, {int port = 8080}) async {
    try {
      _updateStatus(ConnectionStatusEnum.connecting);
      _clientSocket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 10),
      );

      // Configura opções do socket para melhor performance
      _clientSocket!.setOption(SocketOption.tcpNoDelay, true);

      _updateStatus(ConnectionStatusEnum.connected);
      _listenToClient(_clientSocket!);

      // Aguarda um pouco antes de enviar confirmação
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_clientSocket != null &&
            _status == ConnectionStatusEnum.connected) {
          sendMessage('CLIENT_CONNECTED');
        }
      });
      return true;
    } catch (e) {
      _updateStatus(ConnectionStatusEnum.error);
      onError?.call('Erro ao conectar: $e');
      return false;
    }
  }

  // Escutar mensagens do cliente/servidor
  void _listenToClient(Socket socket) {
    socket.listen(
      (data) {
        _buffer += utf8.decode(data);

        // Processa todas as mensagens completas (separadas por \n)
        final lines = _buffer.split('\n');
        _buffer = lines
            .removeLast(); // Mantém a última linha incompleta no buffer

        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            onMessageReceived?.call(line.trim());
          }
        }
      },
      onError: (error) {
        _updateStatus(ConnectionStatusEnum.error);
        onError?.call('Erro na conexão: $error');
      },
      onDone: () {
        _updateStatus(ConnectionStatusEnum.disconnected);
        _buffer = '';
        onMessageReceived?.call('DISCONNECTED');
      },
      cancelOnError: false,
    );
  }

  // Enviar mensagem
  void sendMessage(String message) {
    if (_clientSocket != null && _status == ConnectionStatusEnum.connected) {
      try {
        // Adiciona delimitador \n para separar mensagens
        _clientSocket!.add(utf8.encode('$message\n'));
      } catch (e) {
        _updateStatus(ConnectionStatusEnum.error);
        onError?.call('Erro ao enviar mensagem: $e');
      }
    }
  }

  // Enviar movimento do jogo
  void sendMove(int row, int col, String player) {
    final data = jsonEncode({
      'type': 'move',
      'row': row,
      'col': col,
      'player': player,
    });
    sendMessage(data);
  }

  // Enviar reinício do jogo
  void sendReset() {
    final data = jsonEncode({'type': 'reset'});
    sendMessage(data);
  }

  // Enviar próximo round
  void sendNextRound() {
    final data = jsonEncode({'type': 'nextRound'});
    sendMessage(data);
  }

  // Enviar configuração
  void sendConfig(int maxRounds) {
    final data = jsonEncode({'type': 'config', 'maxRounds': maxRounds});
    sendMessage(data);
  }

  // Fechar conexões
  void disconnect() {
    try {
      _clientSocket?.destroy();
      _serverSocket?.close();
    } catch (e) {
      // Ignora erros ao fechar
    }
    _clientSocket = null;
    _serverSocket = null;
    _buffer = '';
    _updateStatus(ConnectionStatusEnum.disconnected);
  }

  void _updateStatus(ConnectionStatusEnum status) {
    _status = status;
    onConnectionStatusChanged?.call(_status.name);
  }
}
