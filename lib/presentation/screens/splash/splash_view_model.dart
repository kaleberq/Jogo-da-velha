import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/models/local_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/enums/direction_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';

class SplashViewModel extends ChangeNotifier {
  SplashModel _splashState = SplashModel();
  final List<Map<DirectionEnum, int>> _diagonalPositions = [
    {DirectionEnum.row: 0, DirectionEnum.col: 0},
    {DirectionEnum.row: 1, DirectionEnum.col: 1},
    {DirectionEnum.row: 2, DirectionEnum.col: 2},
  ];
  LocalTicTacToeGameModel get game => _game;
  SplashModel get state => _splashState;
  VoidCallback? onLineAnimationReady;

  late final IDeepLinkNavigator _deepLinkNavigator;
  late final IDeepLinkDataSourceChannel _deepLinkChannel;
  late LocalTicTacToeGameModel _game;

  SplashViewModel({
    required IDeepLinkDataSourceChannel deeplinkDataSourceChannel,
    required IDeepLinkNavigator navigator,
    required LocalTicTacToeGameModel ticTacToeGame,
  }) {
    _deepLinkChannel = deeplinkDataSourceChannel;
    _deepLinkNavigator = navigator;
    _game = ticTacToeGame;
  }

  @override
  void dispose() {
    _splashState.boardAnimationTimer?.cancel();
    _splashState = _splashState.copyWith(clearBoardAnimationTimer: true);
    super.dispose();
  }

  void _update(LocalTicTacToeGameModel newState) {
    _game = newState;
    notifyListeners();
  }

  void _updateSplash(SplashModel newState) {
    _splashState = newState;
    notifyListeners();
  }

  void startBoardAnimation() {
    if (_splashState.hasStartedBoardAnimation) return;

    final timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (_splashState.currentIndex < _diagonalPositions.length) {
        final pos = _diagonalPositions[_splashState.currentIndex];
        final row = pos[DirectionEnum.row]!;
        final col = pos[DirectionEnum.col]!;
        _game.board[row][col] = PlayerEnum.x;
        _update(_game);
        _updateSplash(
          _splashState.copyWith(currentIndex: _splashState.currentIndex + 1),
        );
      } else {
        t.cancel();
        _update(_game.copyWith(winningLine: WinningLineModel.diagonalMain()));
        onLineAnimationReady?.call();
      }
    });
    _updateSplash(
      _splashState.copyWith(
        hasStartedBoardAnimation: true,
        boardAnimationTimer: timer,
      ),
    );
  }

  navigate(BuildContext context) async {
    Map<String, dynamic>? route = await _deepLinkChannel.getPendingRoute();

    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    _deepLinkNavigator.navigate(navigator, route);
  }
}
