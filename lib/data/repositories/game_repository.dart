import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/network_service_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/services/qr_code_generator_service_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';

/// Implementação concreta do IGameRepository
/// Usa INetworkService e IQrCodeGeneratorService para operações de rede
class GameRepository implements IGameRepository {
  final INetworkService _networkService;
  final IQrCodeGeneratorService _qrCodeGeneratorService;

  GameRepository({
    required INetworkService networkService,
    required IQrCodeGeneratorService qrCodeGeneratorService,
  })  : _networkService = networkService,
        _qrCodeGeneratorService = qrCodeGeneratorService;

  @override
  set onMessageReceived(Function(String)? callback) {
    _networkService.onMessageReceived = callback;
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
  Future<String?> startServer({int port = 8080}) async {
    return await _networkService.startServer(port: port);
  }

  @override
  Future<HostRoomModel> createHostRoom({int port = 8080}) async {
    final ip = await _networkService.startServer(port: port);
    if (ip == null) return const HostRoomModel();

    Uint8List? qrBytes;
    try {
      qrBytes = await _qrCodeGeneratorService.generateQr(ip);
    } catch (e, stackTrace) {
      developer.log(
        'Falha ao gerar QR (servidor já criado)',
        name: 'GameRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return HostRoomModel(ip: ip, qrCodeBytes: qrBytes);
  }

  @override
  Future<bool> connectToServer(String ip, {int port = 8080}) async {
    return await _networkService.connectToServer(ip, port: port);
  }

  @override
  void disconnect() {
    _networkService.disconnect();
  }

  @override
  void sendMove(int row, int col, PlayerEnum player) {
    _networkService.sendMove(row, col, player);
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
  void sendConfig(int maxRounds) {
    _networkService.sendConfig(maxRounds);
  }
}
