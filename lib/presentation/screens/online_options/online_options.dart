import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/core/dependency_container.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_screen.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/online_game/online_game_view_model.dart';

class OnlineOptions extends StatefulWidget {
  final OnlineOptionsViewModel viewModel;

  const OnlineOptions({super.key, required this.viewModel});

  @override
  State<OnlineOptions> createState() => _OnlineOptionsState();
}

class _OnlineOptionsState extends State<OnlineOptions> {
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
                viewModel: OnlineGameViewModel(
                  isHost: isHost,
                  gameRepository: DependencyContainer.getGameRepository(),
                ),
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
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorCreateServer)));
    }
  }

  Future<void> _connectToServer() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorEmptyIp)));
      return;
    }

    final connected = await widget.viewModel.connectToServer(
      _ipController.text,
    );
    if (!connected && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorConnectServer)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: DSSpacing.md,
              horizontal: DSSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: double.infinity,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 40),
                  ),
                ),
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
                                  context.l10n.createRoomTitle,
                                  style: DSTypographyMedium.labelLarge,
                                ),
                                if (widget.viewModel.onlineOptions.serverIP !=
                                    null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${context.l10n.serverIpLabel} ${widget.viewModel.onlineOptions.serverIP}',
                                        style: DSTypographyRegular.labelSmall,
                                      ),
                                      Text(
                                        context.l10n.waitingPlayer,
                                        style: DSTypographyRegular.labelSmall,
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    context.l10n.createRoomDescription,
                                    style: DSTypographyRegular.labelSmall,
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
                SizedBox(height: DSSpacing.md),
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
                                context.l10n.connectRoomTitle,
                                style: DSTypographyMedium.labelLarge,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _ipController,
                          decoration: InputDecoration(
                            labelText: context.l10n.serverIpInputLabel,
                            hintText: context.l10n.serverIpInputHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DSRadius.sm),
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
                                    context.l10n.connectButton,
                                    style: DSTypographyRegular.labelMedium,
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
        );
      },
    );
  }
}
