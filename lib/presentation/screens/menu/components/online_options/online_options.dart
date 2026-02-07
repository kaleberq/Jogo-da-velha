import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/qr_scanner_screen.dart';

class OnlineOptions extends StatefulWidget {
  final OnlineOptionsViewModel viewModel;

  const OnlineOptions({super.key, required this.viewModel});

  @override
  State<OnlineOptions> createState() => _OnlineOptionsState();
}

class _OnlineOptionsState extends State<OnlineOptions> {
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
      final isHost = widget.viewModel.onlineOptions.qrCodeBytes != null;
      Future.microtask(() {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamed(RoutesEnum.onlineGame.path, arguments: (isHost: isHost));
        }
      });
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    widget.viewModel.dispose();
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

  Future<void> _openQrScanner() async {
    if (!mounted) return;

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (scannerContext) => QrScannerScreen(
          onQrCodeScanned: (ip) {
            Navigator.of(scannerContext).pop(ip);
          },
        ),
      ),
    );

    if (result != null && mounted) {
      final connected = await widget.viewModel.connectToServer(result);
      if (!connected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorConnectServer)),
        );
      }
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
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 40),
                  ),
                ),
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DSRadius.md),
                    onTap:
                        widget.viewModel.onlineOptions.isCreatingServer ||
                            widget.viewModel.onlineOptions.qrCodeBytes != null
                        ? null
                        : _createServer,
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                                    if (widget
                                            .viewModel
                                            .onlineOptions
                                            .qrCodeBytes !=
                                        null)
                                      Text(
                                        context.l10n.waitingPlayer,
                                        style: DSTypographyRegular.labelSmall,
                                      )
                                    else
                                      Text(
                                        context.l10n.createRoomDescription,
                                        style: DSTypographyRegular.labelSmall,
                                      ),
                                  ],
                                ),
                              ),
                              if (widget.viewModel.onlineOptions.qrCodeBytes ==
                                  null)
                                const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                          if (widget.viewModel.onlineOptions.qrCodeBytes !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(top: DSSpacing.lg),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Escaneie o QR Code para conectar',
                                      style: DSTypographyMedium.labelMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: DSSpacing.md),
                                    Container(
                                      padding: const EdgeInsets.all(
                                        DSSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          DSRadius.md,
                                        ),
                                        border: Border.all(
                                          color: DSColors.resolveGreyColor(
                                            context,
                                          ),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.memory(
                                        widget
                                            .viewModel
                                            .onlineOptions
                                            .qrCodeBytes!,
                                        width: 250,
                                        height: 250,
                                        fit: BoxFit.contain,
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                widget.viewModel.onlineOptions.isConnecting
                                ? null
                                : _openQrScanner,
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
                            icon: widget.viewModel.onlineOptions.isConnecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.qr_code_scanner),
                            label: widget.viewModel.onlineOptions.isConnecting
                                ? Text(
                                    'Conectando...',
                                    style: DSTypographyRegular.labelMedium,
                                  )
                                : Text(
                                    'Escanear QR Code',
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
