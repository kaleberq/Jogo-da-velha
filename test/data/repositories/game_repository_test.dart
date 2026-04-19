import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';
import 'package:jogo_da_velha/data/repositories/game_repository.dart';
import 'package:jogo_da_velha/domain/enums/config_data_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/connection_message_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_payload_key_enum.dart';
import 'package:jogo_da_velha/domain/enums/game_message_type_enum.dart';
import 'package:jogo_da_velha/domain/enums/request_move_data_key_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/qr_code_generator_service_interface.dart';

class FakeNetworkService implements INetworkService {
  Function(String)? _onMessageReceived;
  Function(String)? _onConnectionStatusChanged;
  Function(String)? _onError;
  void Function(OnlineTicTacToeGameDTO)? _onGameStateReceived;

  String? startServerIp;
  bool connectResult = true;
  bool disconnectCalled = false;
  bool resetCalled = false;
  bool nextRoundCalled = false;
  int? sentConfigMaxRounds;
  ({int row, int col})? sentMove;
  OnlineTicTacToeGameDTO? sentGameState;

  @override
  set onMessageReceived(Function(String)? callback) {
    _onMessageReceived = callback;
  }

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _onConnectionStatusChanged = callback;
  }

  @override
  set onError(Function(String)? callback) {
    _onError = callback;
  }

  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameDTO)? callback) {
    _onGameStateReceived = callback;
  }

  @override
  Future<String?> getLocalIP() async => '127.0.0.1';

  @override
  Future<String?> startServer({required int port}) async => startServerIp;

  @override
  Future<bool> connectToServer(String ip, {required int port}) async {
    return connectResult;
  }

  @override
  void disconnect() {
    disconnectCalled = true;
  }

  @override
  void sendReset() {
    resetCalled = true;
  }

  @override
  void sendNextRound() {
    nextRoundCalled = true;
  }

  @override
  void sendConfig({required int maxRounds}) {
    sentConfigMaxRounds = maxRounds;
  }

  @override
  void sendGameState(OnlineTicTacToeGameDTO dto) {
    sentGameState = dto;
  }

  @override
  void sendRequestMove(int row, int col) {
    sentMove = (row: row, col: col);
  }

  void emitIncomingMessage(String message) {
    _onMessageReceived?.call(message);
  }

  void emitGameState(OnlineTicTacToeGameDTO dto) {
    _onGameStateReceived?.call(dto);
  }
}

class FakeQrCodeGeneratorService implements IQrCodeGeneratorService {
  Uint8List? valueToReturn;
  Object? errorToThrow;

  @override
  Future<Uint8List?> generateQr(String data) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return valueToReturn;
  }
}

void main() {
  group('GameRepository', () {
    late FakeNetworkService network;
    late FakeQrCodeGeneratorService qr;
    late GameRepository repository;

    setUp(() {
      network = FakeNetworkService();
      qr = FakeQrCodeGeneratorService();
      repository = GameRepository(
        networkService: network,
        qrCodeGeneratorService: qr,
      );
    });

    test('forwards connection message to onMessageReceived', () {
      String? received;
      repository.onMessageReceived = (value) => received = value;

      network.emitIncomingMessage(ConnectionMessageEnum.connected.value);

      expect(received, ConnectionMessageEnum.connected.value);
    });

    test('parses requestMove and triggers onRequestMove callback', () {
      int? row;
      int? col;
      repository.onRequestMove = (r, c) {
        row = r;
        col = c;
      };

      final payload = jsonEncode({
        GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.requestMove.value,
        RequestMoveDataKeyEnum.row.key: 1,
        RequestMoveDataKeyEnum.col.key: 2,
      });
      network.emitIncomingMessage(payload);

      expect(row, 1);
      expect(col, 2);
    });

    test('parses config and triggers onConfigReceived callback', () {
      int? maxRounds;
      repository.onConfigReceived = (value) => maxRounds = value;

      final payload = jsonEncode({
        GameMessagePayloadKeyEnum.type.key: GameMessageTypeEnum.config.value,
        ConfigDataKeyEnum.maxRounds.key: 7,
      });
      network.emitIncomingMessage(payload);

      expect(maxRounds, 7);
    });

    test('converts DTO to model in onGameStateReceived', () {
      String? currentPlayer;
      repository.onGameStateReceived = (model) {
        currentPlayer = model.currentPlayer.name;
      };

      network.emitGameState(
        const OnlineTicTacToeGameDTO(
          board: [
            ['none', 'none', 'none'],
            ['none', 'none', 'none'],
            ['none', 'none', 'none'],
          ],
          currentPlayer: 'o',
          winner: null,
          winningLine: null,
          isGameOver: false,
          scoreX: 0,
          scoreO: 0,
          currentRound: 1,
          maxRounds: 5,
        ),
      );

      expect(currentPlayer, 'o');
    });

    test('createHostRoom returns empty model when server does not start', () async {
      network.startServerIp = null;

      final room = await repository.createHostRoom();

      expect(room.ip, isNull);
      expect(room.qrCodeBytes, isNull);
    });

    test('createHostRoom returns IP and qrCodeBytes when successful', () async {
      network.startServerIp = '192.168.0.10';
      qr.valueToReturn = Uint8List.fromList([1, 2, 3]);

      final room = await repository.createHostRoom();

      expect(room.ip, '192.168.0.10');
      expect(room.qrCodeBytes, Uint8List.fromList([1, 2, 3]));
    });

    test('delegates sendConfig to network service', () {
      repository.sendConfig(maxRounds: 9);

      expect(network.sentConfigMaxRounds, 9);
    });
  });
}
