import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/tic_tac_toe_screen.dart';
import 'package:jogo_da_velha/data/network/network_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final NetworkService _networkService = NetworkService();
  final TextEditingController _ipController = TextEditingController();
  bool _isCreatingServer = false;
  String? _serverIP;
  bool _isConnecting = false;
  bool _navigatingToGame = false;

  @override
  void initState() {
    super.initState();
    _networkService.onMessageReceived = (message) {
      if (message == 'CONNECTED' && _isCreatingServer && mounted) {
        _navigatingToGame = true;
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TicTacToeScreen(
                  networkService: _networkService,
                  isHost: true,
                ),
              ),
            );
          }
        });
      }
    };
    _networkService.onError = (error) {
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
            setState(() {
              _isCreatingServer = false;
              _isConnecting = false;
              _serverIP = null;
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
    if (!_navigatingToGame) {
      _networkService.disconnect();
    }
    super.dispose();
  }

  Future<void> _createServer() async {
    setState(() {
      _isCreatingServer = true;
    });

    final ip = await _networkService.startServer();
    if (ip != null && mounted) {
      setState(() {
        _serverIP = ip;
      });
    } else if (mounted) {
      setState(() {
        _isCreatingServer = false;
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
      _isConnecting = true;
    });

    final connected = await _networkService.connectToServer(_ipController.text);
    if (connected && mounted) {
      _navigatingToGame = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              TicTacToeScreen(networkService: _networkService, isHost: false),
        ),
      );
    } else if (mounted) {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jogo da Velha'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Escolha um modo de jogo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // Modo Local
              Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const TicTacToeScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_android,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo Local',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Jogue no mesmo dispositivo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Criar Servidor (Host)
              Card(
                elevation: 4,
                color: _serverIP != null ? Colors.green.shade50 : null,
                child: InkWell(
                  onTap: _isCreatingServer || _serverIP != null
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
                          color: _serverIP != null ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Criar Sala',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_serverIP != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IP: $_serverIP',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Aguardando jogador se conectar...',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              else if (_isCreatingServer)
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
                        if (_isCreatingServer)
                          const CircularProgressIndicator()
                        else if (_serverIP != null)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                          onPressed: _isConnecting ? null : _connectToServer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isConnecting
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
