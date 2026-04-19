import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/online_options_state.dart';

void main() {
  group('OnlineOptionsState', () {
    test('derived flags reflect flow state', () {
      const state = OnlineOptionsState(flowState: OnlineOptionsFlowEnum.connecting);

      expect(state.isConnecting, isTrue);
      expect(state.isCreatingServer, isFalse);
      expect(state.shouldNavigateToGame, isFalse);
    });

    test('copyWith clearQrAndServer removes server data', () {
      final state = OnlineOptionsState(
        flowState: OnlineOptionsFlowEnum.serverReady,
        serverIp: '192.168.0.2',
        qrCodeBytes: Uint8List.fromList([1]),
      );

      final cleared = state.copyWith(
        flowState: OnlineOptionsFlowEnum.idle,
        clearQrAndServer: true,
      );

      expect(cleared.serverIp, isNull);
      expect(cleared.qrCodeBytes, isNull);
      expect(cleared.hasQrCode, isFalse);
      expect(cleared.flowState, OnlineOptionsFlowEnum.idle);
    });
  });
}
