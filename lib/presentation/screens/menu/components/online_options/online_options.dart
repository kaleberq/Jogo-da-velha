import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/routes_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/online_options_view_model.dart';
import 'package:jogo_da_velha/presentation/screens/qr_scanner/qr_scanner_screen.dart';

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
    widget.viewModel.onError = _showError;
  }

  void _showError(String message, [Object? error, StackTrace? stackTrace]) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onViewModelChanged() {
    if (!mounted || _hasNavigated) return;

    final state = widget.viewModel.viewState;
    if (!state.shouldNavigateToGame) return;

    _hasNavigated = true;
    final playerRole = state.playerRole;
    Future.microtask(() {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.of(
        context,
      ).pushNamed(RoutesEnum.onlineGame.path, arguments: (playerRole: playerRole));
    });
  }

  @override
  void dispose() {
    widget.viewModel.onError = null;
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
        final state = widget.viewModel.viewState;
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
                  child: GestureDetector(
                    onTap: state.isCreatingServer || state.hasQrCode
                        ? null
                        : _createServer,
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: DSSpacing.md,
                        children: [
                          Row(
                            spacing: DSSpacing.md,
                            children: [
                              Icon(Icons.wifi, size: 48),
                              Expanded(
                                child: Column(
                                  spacing: DSSpacing.xs,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.createRoomTitle,
                                      style: DSTypographyMedium.labelLarge,
                                    ),
                                    if (state.hasQrCode)
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
                              if (!state.hasQrCode)
                                const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                          if (state.hasQrCode && state.qrCodeBytes != null)
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    context.l10n.scanQrCodeToConnect,
                                    style: DSTypographyMedium.labelMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: DSSpacing.md),
                                  Container(
                                    padding: const EdgeInsets.all(DSSpacing.md),
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
                                      state.qrCodeBytes!,
                                      width: 250,
                                      height: 250,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!state.hasQrCode)
                  Column(
                    children: [
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
                                  onPressed: state.isConnecting
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
                                  icon: state.isConnecting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.qr_code_scanner),
                                  label: state.isConnecting
                                      ? Text(
                                          context.l10n.connecting,
                                          style:
                                              DSTypographyRegular.labelMedium,
                                        )
                                      : Text(
                                          context.l10n.scanQrCode,
                                          style:
                                              DSTypographyRegular.labelMedium,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
