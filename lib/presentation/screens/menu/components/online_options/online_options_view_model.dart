import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'package:jogo_da_velha/domain/constants/network_message_constants.dart';
import 'package:jogo_da_velha/domain/enums/online_options_flow_enum.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';
import 'package:jogo_da_velha/domain/models/host_room_model.dart';
import 'package:jogo_da_velha/presentation/screens/menu/components/online_options/online_options_state.dart';

/// Callback de erro da UI. Recebe mensagem e opcionalmente stackTrace.
typedef OnlineOptionsErrorCallback =
    void Function(String message, [Object? error, StackTrace? stackTrace]);

class OnlineOptionsViewModel extends ChangeNotifier {
  final IGameRepository _gameRepository;

  OnlineOptionsState _viewState = const OnlineOptionsState(
    flowState: OnlineOptionsFlowEnum.idle,
  );
  bool _disposed = false;

  OnlineOptionsViewModel({required IGameRepository gameRepository})
      : _gameRepository = gameRepository {
    _setupNetworkCallbacks();
  }

  /// Estado imutável para a UI. Nunca exponha o modelo mutável.
  OnlineOptionsState get viewState => _viewState;

  /// Callback de erro definido pela UI. Só é invocado se o ViewModel não foi disposed.
  OnlineOptionsErrorCallback? onError;

  void _setupNetworkCallbacks() {
    _gameRepository.onMessageReceived = _onMessageReceived;
    _gameRepository.onError = _onError;
  }

  void _clearNetworkCallbacks() {
    _gameRepository.onMessageReceived = null;
    _gameRepository.onError = null;
  }

  void _onMessageReceived(String message) {
    if (_disposed) return;
    if (message != NetworkMessageConstants.peerConnected) return;
    if (_viewState.flowState != OnlineOptionsFlowEnum.serverReady) {
      developer.log(
        'CONNECTED recebido em estado ${_viewState.flowState}; ignorado até serverReady.',
        name: 'OnlineOptionsViewModel',
      );
      return;
    }
    _updateState(
      _viewState.copyWith(flowState: OnlineOptionsFlowEnum.connectedNavigating),
    );
  }

  void _onError(String error) {
    if (_disposed) return;
    _updateState(
      _viewState.copyWith(
        flowState: OnlineOptionsFlowEnum.idle,
        clearQrAndServer: true,
      ),
    );
    onError?.call(error);
  }

  void _updateState(OnlineOptionsState next) {
    if (_disposed) return;
    _viewState = next;
    notifyListeners();
  }

  Future<String?> createServer() async {
    if (_viewState.flowState != OnlineOptionsFlowEnum.idle) return null;

    _updateState(
      _viewState.copyWith(flowState: OnlineOptionsFlowEnum.creatingServer),
    );

    HostRoomModel result;
    try {
      result = await _gameRepository.createHostRoom();
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao criar servidor',
        name: 'OnlineOptionsViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      if (!_disposed) {
        _updateState(
          _viewState.copyWith(
            flowState: OnlineOptionsFlowEnum.idle,
            clearQrAndServer: true,
          ),
        );
        onError?.call('Erro ao criar servidor: $e', e, stackTrace);
      }
      return null;
    }

    if (_disposed) return null;
    if (result.ip == null) {
      _updateState(_viewState.copyWith(flowState: OnlineOptionsFlowEnum.idle));
      return null;
    }

    _updateState(
      _viewState.copyWith(
        flowState: OnlineOptionsFlowEnum.serverReady,
        qrCodeBytes: result.qrCodeBytes,
        serverIp: result.ip,
        isHost: true,
      ),
    );
    return result.ip;
  }

  Future<bool> connectToServer(String ip) async {
    if (_viewState.flowState != OnlineOptionsFlowEnum.idle) return false;

    _updateState(
      _viewState.copyWith(flowState: OnlineOptionsFlowEnum.connecting),
    );

    final connected = await _gameRepository.connectToServer(ip);
    if (_disposed) return false;

    if (connected) {
      _updateState(
        _viewState.copyWith(
          flowState: OnlineOptionsFlowEnum.connectedNavigating,
          isHost: false,
        ),
      );
      return true;
    }

    _updateState(_viewState.copyWith(flowState: OnlineOptionsFlowEnum.idle));
    return false;
  }

  void resetServerState() {
    _updateState(
      _viewState.copyWith(
        flowState: OnlineOptionsFlowEnum.idle,
        clearQrAndServer: true,
      ),
    );
  }

  void resetConnectionState() {
    if (_viewState.flowState == OnlineOptionsFlowEnum.connecting) {
      _updateState(_viewState.copyWith(flowState: OnlineOptionsFlowEnum.idle));
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Não limpar callbacks ao navegar para o jogo: a tela do jogo usa o mesmo
    // NetworkService (singleton) e vai sobrescrever os callbacks. Limpar aqui
    // zeraria os handlers antes da nova tela registrar os dela e as jogadas
    // deixariam de ser recebidas.
    if (!_viewState.shouldNavigateToGame) {
      _clearNetworkCallbacks();
      _gameRepository.disconnect();
    }
    super.dispose();
  }
}
