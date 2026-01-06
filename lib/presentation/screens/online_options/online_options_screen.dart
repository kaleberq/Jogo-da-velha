import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';

class OnlineOptionsScreen extends StatefulWidget {
  const OnlineOptionsScreen({super.key});

  @override
  State<OnlineOptionsScreen> createState() => _OnlineOptionsScreenState();
}

class _OnlineOptionsScreenState extends State<OnlineOptionsScreen> {
  final OnlineOptionsViewModel _viewModel = OnlineOptionsViewModel();
  final TextEditingController _ipController = TextEditingController();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    };
  }

  void _onViewModelChanged() {
    if (!mounted || _hasNavigated) return;

    // Navega para o jogo quando conectado
    if (_viewModel.onlineOptions.navigatingToGame) {
      _hasNavigated = true;
      final isHost = _viewModel.onlineOptions.serverIP != null;
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnlineGameScreen(isHost: isHost),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _createServer() async {
    final ip = await _viewModel.createServer();
    if (ip == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao criar servidor')));
    }
  }

  Future<void> _connectToServer() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o IP do servidor')),
      );
      return;
    }

    final connected = await _viewModel.connectToServer(_ipController.text);
    if (!connected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao conectar ao servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
                    color: _viewModel.onlineOptions.serverIP != null
                        ? Colors.green.shade50
                        : null,
                    child: InkWell(
                      onTap:
                          _viewModel.onlineOptions.isCreatingServer ||
                              _viewModel.onlineOptions.serverIP != null
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
                              color: _viewModel.onlineOptions.serverIP != null
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
                                  if (_viewModel.onlineOptions.serverIP != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'IP: ${_viewModel.onlineOptions.serverIP}',
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
                                  else if (_viewModel
                                      .onlineOptions
                                      .isCreatingServer)
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
                            if (_viewModel.onlineOptions.isCreatingServer)
                              const CircularProgressIndicator()
                            else if (_viewModel.onlineOptions.serverIP != null)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
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
                              onPressed: _viewModel.onlineOptions.isConnecting
                                  ? null
                                  : _connectToServer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _viewModel.onlineOptions.isConnecting
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
      },
    );
  }
}
