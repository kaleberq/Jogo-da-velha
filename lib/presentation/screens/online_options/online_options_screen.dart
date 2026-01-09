import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

class OnlineOptionsScreen extends StatefulWidget {
  final OnlineOptionsViewModel viewModel;

  const OnlineOptionsScreen({super.key, required this.viewModel});

  @override
  State<OnlineOptionsScreen> createState() => _OnlineOptionsScreenState();
}

class _OnlineOptionsScreenState extends State<OnlineOptionsScreen> {
  final TextEditingController _ipController = TextEditingController();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    widget.viewModel.onError = (error) {
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
    if (widget.viewModel.onlineOptions.navigatingToGame) {
      _hasNavigated = true;
      final isHost = widget.viewModel.onlineOptions.serverIP != null;
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OnlineGameScreen(
                viewModel: OnlineGameViewModel(isHost: isHost),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    widget.viewModel.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _createServer() async {
    final ip = await widget.viewModel.createServer();
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

    final connected = await widget.viewModel.connectToServer(
      _ipController.text,
    );
    if (!connected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao conectar ao servidor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Jogar Online', style: DSTypographySemiBold.labelLarge),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: DSSpacing.md,
                horizontal: DSSpacing.lg,
              ),
              child: Column(
                spacing: DSSpacing.lg,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Escolha uma opção',
                    style: DSTypographySemiBold.labelLarge,
                    textAlign: TextAlign.center,
                  ),

                  // Criar Servidor (Host)
                  Card(
                    child: InkWell(
                      onTap:
                          widget.viewModel.onlineOptions.isCreatingServer ||
                              widget.viewModel.onlineOptions.serverIP != null
                          ? null
                          : _createServer,
                      child: Padding(
                        padding: const EdgeInsets.all(DSSpacing.lg),
                        child: Row(
                          spacing: DSSpacing.md,
                          children: [
                            Icon(Icons.wifi, size: 48),
                            Expanded(
                              child: Column(
                                spacing: 4,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Criar uma Sala',
                                    style: DSTypographySemiBold.labelLarge,
                                  ),
                                  if (widget.viewModel.onlineOptions.serverIP !=
                                      null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'IP: ${widget.viewModel.onlineOptions.serverIP}',
                                          style: DSTypographyMedium.labelSmall,
                                        ),
                                        Text(
                                          'Aguardando jogador se conectar...',
                                          style: DSTypographyMedium.labelSmall,
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Criar uma sala para outros se conectarem',
                                      style: DSTypographyMedium.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                            if (widget.viewModel.onlineOptions.serverIP == null)
                              const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: Column(
                        spacing: DSSpacing.md,
                        children: [
                          Row(
                            spacing: DSSpacing.md,
                            children: [
                              Icon(Icons.wifi_find, size: 48),
                              Expanded(
                                child: Text(
                                  'Conectar a uma Sala',
                                  style: DSTypographySemiBold.labelLarge,
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            controller: _ipController,
                            decoration: InputDecoration(
                              labelText: 'IP do Servidor',
                              hintText: 'Ex: 192.168.1.100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DSRadius.sm,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.computer),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  widget.viewModel.onlineOptions.isConnecting
                                  ? null
                                  : _connectToServer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: DSSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    DSRadius.sm,
                                  ),
                                ),
                              ),
                              child: widget.viewModel.onlineOptions.isConnecting
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      'Conectar',
                                      style: DSTypographySemiBold.labelMedium,
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
