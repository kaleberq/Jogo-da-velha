import 'dart:convert';
import 'dart:typed_data';

import 'package:jogo_da_velha/data/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/qr_code_generator_service_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';

/// Implementação concreta do IGameRepository.
/// Usa toJson/fromJson do modelo (como gd-app-4), sem serializer separado.
class GameRepository implements IGameRepository {
  final INetworkService _networkService;
  final IQrCodeGeneratorService _qrCodeGeneratorService;
  final int _port = 8080;

  Function(String)? _onMessageReceived;
  void Function(OnlineTicTacToeGameModel)? _onGameStateReceived;

  GameRepository({
    required INetworkService networkService,
    required IQrCodeGeneratorService qrCodeGeneratorService,
  }) : _networkService = networkService,
       _qrCodeGeneratorService = qrCodeGeneratorService {
    _networkService.onMessageReceived = _handleIncomingMessage;
  }

  void _handleIncomingMessage(String message) {
    if (message == 'DISCONNECTED' ||
        message == 'SERVER_CONNECTED' ||
        message == 'CLIENT_CONNECTED' ||
        message == 'CONNECTED') {
      _onMessageReceived?.call(message);
      return;
    }
    try {
      final data = jsonDecode(message);
      final type = data['type'] as String?;
      if (type == 'gameState') {
        final model = OnlineTicTacToeGameModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        _onGameStateReceived?.call(model);
      } else {
        _onMessageReceived?.call(message);
      }
    } catch (_) {
      _onMessageReceived?.call(message);
    }
  }

  @override
  set onMessageReceived(Function(String)? callback) {
    _onMessageReceived = callback;
  }

  @override
  set onGameStateReceived(void Function(OnlineTicTacToeGameModel)? callback) {
    _onGameStateReceived = callback;
  }

  @override
  set onConnectionStatusChanged(Function(String)? callback) {
    _networkService.onConnectionStatusChanged = callback;
  }

  @override
  set onError(Function(String)? callback) {
    _networkService.onError = callback;
  }

  @override
  Future<String?> startServer() async {
    return await _networkService.startServer(port: _port);
  }

  @override
  Future<HostRoomModel> createHostRoom() async {
    final ip = await _networkService.startServer(port: _port);
    if (ip == null) return const HostRoomModel();

    Uint8List? qrBytes;
    try {
      qrBytes = await _qrCodeGeneratorService.generateQr(ip);
    } catch (e, _) {
      return throw Exception(e);
    }
    return HostRoomModel(ip: ip, qrCodeBytes: qrBytes);
  }

  @override
  Future<bool> connectToServer({required String ip}) async {
    return await _networkService.connectToServer(ip, port: _port);
  }

  @override
  void disconnect() {
    _networkService.disconnect();
  }

  @override
  void sendMove({
    required int row,
    required int col,
    required PlayerEnum player,
  }) {
    _networkService.sendMove(row: row, col: col, player: player);
  }

  @override
  void sendReset() {
    _networkService.sendReset();
  }

  @override
  void sendNextRound() {
    _networkService.sendNextRound();
  }

  @override
  void sendConfig({required int maxRounds}) {
    _networkService.sendConfig(maxRounds: maxRounds);
  }

  @override
  void sendRequestMove(int row, int col) {
    _networkService.sendRequestMove(row, col);
  }

  @override
  void sendGameState(Map<String, dynamic> state) {
    _networkService.sendGameState(state);
  }

  @override
  void sendCurrentGameState(dynamic game) {
    if (game is OnlineTicTacToeGameModel) {
      _networkService.sendGameState(game.toJson());
    }
  }
}
