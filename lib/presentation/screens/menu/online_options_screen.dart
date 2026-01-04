import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/models/menu_model.dart';
import 'package:jogo_da_velha/domain/repositories/game_repository.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';

class OnlineOptionsScreen extends StatefulWidget {
  const OnlineOptionsScreen({super.key});

  @override
  State<OnlineOptionsScreen> createState() => _OnlineOptionsScreenState();
}

class _OnlineOptionsScreenState extends State<OnlineOptionsScreen> {
  final GameRepository _gameRepository = GameRepository();
  final MenuModel _menu = MenuModel();
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameRepository.onMessageReceived = (message) {
      if (message == 'CONNECTED' && _menu.isCreatingServer && mounted) {
        setState(() {
          _menu.navigatingToGame = true;
        });
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OnlineGameScreen(
                  gameRepository: _gameRepository,
                  isHost: true,
                ),
              ),
            );
          }
        });
      }
    };
    _gameRepository.onError = (error) {
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
            setState(() {
              _menu.resetServerState();
              _menu.resetConnectionState();
            });
          }
        });
      }
    };
  }

  @override
  void dispose() {
    _ipController.dispose();
    // Só desconecta se não estiver navegando para o jogo
    if (!_menu.navigatingToGame) {
      _gameRepository.disconnect();
    }
    super.dispose();
  }

  Future<void> _createServer() async {
    setState(() {
      _menu.isCreatingServer = true;
    });

    final ip = await _gameRepository.startServer();
    if (ip != null && mounted) {
      setState(() {
        _menu.serverIP = ip;
      });
    } else if (mounted) {
      setState(() {
        _menu.isCreatingServer = false;
      });
    }
  }

  Future<void> _connectToServer() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o IP do servidor')),
      );
      return;
    }

    setState(() {
      _menu.isConnecting = true;
    });

    final connected = await _gameRepository.connectToServer(_ipController.text);
    if (connected && mounted) {
      setState(() {
        _menu.navigatingToGame = true;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              OnlineGameScreen(gameRepository: _gameRepository, isHost: false),
        ),
      );
    } else if (mounted) {
      setState(() {
        _menu.isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jogar Online'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 24,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Escolha uma opção',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              // Criar Servidor (Host)
              Card(
                elevation: 4,
                color: _menu.serverIP != null ? Colors.green.shade50 : null,
                child: InkWell(
                  onTap: _menu.isCreatingServer || _menu.serverIP != null
                      ? null
                      : _createServer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi,
                          size: 48,
                          color: _menu.serverIP != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Criar uma Sala',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_menu.serverIP != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IP: ${_menu.serverIP}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Text(
                                      'Aguardando jogador se conectar...',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              else if (_menu.isCreatingServer)
                                const Text(
                                  'Criando servidor...',
                                  style: TextStyle(color: Colors.orange),
                                )
                              else
                                const Text(
                                  'Criar uma sala para outros se conectarem',
                                  style: TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        if (_menu.isCreatingServer)
                          const CircularProgressIndicator()
                        else if (_menu.serverIP != null)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),

              // Conectar ao Servidor (Cliente)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wifi_find,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Conectar a uma Sala',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'IP do Servidor',
                          hintText: 'Ex: 192.168.1.100',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.computer),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _menu.isConnecting
                              ? null
                              : _connectToServer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _menu.isConnecting
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Conectar',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
