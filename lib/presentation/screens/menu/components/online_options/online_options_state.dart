import 'dart:typed_data';

import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';

/// Estado imutável da tela de opções online exposto para a UI.
class OnlineOptionsState {
  final OnlineOptionsFlowEnum flowState;
  final Uint8List? qrCodeBytes;
  final String? serverIp;
  final bool isHost;

  const OnlineOptionsState({
    required this.flowState,
    this.qrCodeBytes,
    this.serverIp,
    this.isHost = false,
  });

  bool get isCreatingServer => flowState == OnlineOptionsFlowEnum.creatingServer;
  bool get isServerReady => flowState == OnlineOptionsFlowEnum.serverReady;
  bool get isConnecting => flowState == OnlineOptionsFlowEnum.connecting;
  bool get shouldNavigateToGame =>
      flowState == OnlineOptionsFlowEnum.connectedNavigating;
  bool get hasQrCode => qrCodeBytes != null;

  OnlineOptionsState copyWith({
    OnlineOptionsFlowEnum? flowState,
    Uint8List? qrCodeBytes,
    String? serverIp,
    bool? isHost,
    bool clearQrAndServer = false,
  }) {
    return OnlineOptionsState(
      flowState: flowState ?? this.flowState,
      qrCodeBytes: clearQrAndServer ? null : (qrCodeBytes ?? this.qrCodeBytes),
      serverIp: clearQrAndServer ? null : (serverIp ?? this.serverIp),
      isHost: isHost ?? this.isHost,
    );
  }
}
