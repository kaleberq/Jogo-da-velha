import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';
import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';
import 'package:jogo_da_velha/domain/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/online_options_view_model.dart';

class FakeGameRepository implements IGameRepository {
  Function(String)? messageCallback;
  Function(String)? errorCallback;
  Future<HostRoomModel> Function()? onCreateHostRoom;
  Future<bool> Function(String ip)? onConnectToServer;
  bool disconnectCalled = false;

  @override
  set onMessageReceived(Function(String)? callback) => messageCallback = callback;

  @override
  set onError(Function(String)? callback) => errorCallback = callback;

  @override
  set onConnectionStatusChanged(Function(String)? callback) {}

  @override
  set onConfigReceived(void Function(int p1)? callback) {}

  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameModel p1)? callback) {}

  @override
  set onNextRoundReceived(void Function()? callback) {}

  @override
  set onRequestMove(void Function(int p1, int p2)? callback) {}

  @override
  set onResetReceived(void Function()? callback) {}

  @override
  Future<bool> connectToServer({required String ip}) async {
    return onConnectToServer?.call(ip) ?? false;
  }

  @override
  Future<HostRoomModel> createHostRoom() async {
    return onCreateHostRoom?.call() ?? const HostRoomModel();
  }

  @override
  void disconnect() {
    disconnectCalled = true;
  }

  @override
  void sendConfig({required int maxRounds}) {}

  @override
  void sendCurrentGameState(OnlineTicTacToeGameModel game) {}

  @override
  void sendNextRound() {}

  @override
  void sendRequestMove(int row, int col) {}

  @override
  void sendReset() {}

  @override
  Future<String?> startServer() async => null;
}

void main() {
  group('OnlineOptionsViewModel', () {
    test('createServer sets serverReady and host data on success', () async {
      final repo = FakeGameRepository()
        ..onCreateHostRoom = () async => HostRoomModel(
          ip: '192.168.0.2',
          qrCodeBytes: Uint8List.fromList([1, 2, 3]),
        );
      final viewModel = OnlineOptionsViewModel(gameRepository: repo);

      final ip = await viewModel.createServer();

      expect(ip, '192.168.0.2');
      expect(viewModel.viewState.flowState, OnlineOptionsFlowEnum.serverReady);
      expect(viewModel.viewState.serverIp, '192.168.0.2');
      expect(viewModel.viewState.qrCodeBytes, isNotNull);
      expect(viewModel.viewState.hasQrCode, isTrue);
    });

    test('connectToServer sets connectedNavigating on success', () async {
      final repo = FakeGameRepository()
        ..onConnectToServer = (_) async => true;
      final viewModel = OnlineOptionsViewModel(gameRepository: repo);

      final connected = await viewModel.connectToServer('192.168.0.2');

      expect(connected, isTrue);
      expect(
        viewModel.viewState.flowState,
        OnlineOptionsFlowEnum.connectedNavigating,
      );
      expect(viewModel.viewState.shouldNavigateToGame, isTrue);
    });

    test('reacts to peer connected message only when serverReady', () async {
      final repo = FakeGameRepository()
        ..onCreateHostRoom = () async => const HostRoomModel(ip: '10.0.0.2');
      final viewModel = OnlineOptionsViewModel(gameRepository: repo);

      repo.messageCallback?.call(NetworkMessageConstants.peerConnected);
      expect(viewModel.viewState.flowState, OnlineOptionsFlowEnum.idle);

      await viewModel.createServer();
      repo.messageCallback?.call(NetworkMessageConstants.peerConnected);

      expect(
        viewModel.viewState.flowState,
        OnlineOptionsFlowEnum.connectedNavigating,
      );
    });
  });
}
