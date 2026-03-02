import 'dart:typed_data';

import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';

/// Estado imutável da tela de opções online exposto para a UI.
class OnlineOptionsState {
  final OnlineOptionsFlowEnum flowState;
  final Uint8List? qrCodeBytes;
  final String? serverIp;
  final PlayerRole playerRole;

  const OnlineOptionsState({
    required this.flowState,
    this.qrCodeBytes,
    this.serverIp,
    this.playerRole = PlayerRole.guest,
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
    PlayerRole? playerRole,
    bool clearQrAndServer = false,
  }) {
    return OnlineOptionsState(
      flowState: flowState ?? this.flowState,
      qrCodeBytes: clearQrAndServer ? null : (qrCodeBytes ?? this.qrCodeBytes),
      serverIp: clearQrAndServer ? null : (serverIp ?? this.serverIp),
      playerRole: playerRole ?? this.playerRole,
    );
  }
}
