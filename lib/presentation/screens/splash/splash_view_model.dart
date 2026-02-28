import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/direction_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/data/models/splash_model.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';

class SplashViewModel extends ChangeNotifier {
  final SplashModel _splashState = SplashModel();
  final List<Map<DirectionEnum, int>> _diagonalPositions = [
    {DirectionEnum.row: 0, DirectionEnum.col: 0},
    {DirectionEnum.row: 1, DirectionEnum.col: 1},
    {DirectionEnum.row: 2, DirectionEnum.col: 2},
  ];
  TicTacToeGameModel get game => _game;
  SplashModel get state => _splashState;
  VoidCallback? onLineAnimationReady;

  late final IDeepLinkNavigator _deepLinkNavigator;
  late final IDeepLinkDataSourceChannel _deepLinkChannel;
  late final TicTacToeGameModel _game;

  SplashViewModel({
    required IDeepLinkDataSourceChannel deeplinkDataSourceChannel,
    required IDeepLinkNavigator navigator,
    required TicTacToeGameModel ticTacToeGame,
  }) {
    _deepLinkChannel = deeplinkDataSourceChannel;
    _deepLinkNavigator = navigator;
    _game = ticTacToeGame;
  }

  @override
  void dispose() {
    _splashState.boardAnimationTimer?.cancel();
    _splashState.boardAnimationTimer = null;
    super.dispose();
  }

  void startBoardAnimation() {
    if (_splashState.hasStartedBoardAnimation) return;

    _splashState.hasStartedBoardAnimation = true;
    _splashState.boardAnimationTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (_splashState.currentIndex < _diagonalPositions.length) {
          final pos = _diagonalPositions[_splashState.currentIndex];
          game.board[pos[DirectionEnum.row]!][pos[DirectionEnum.col]!] =
              PlayerEnum.x;
          _splashState.currentIndex++;
          notifyListeners();
        } else {
          timer.cancel();
          _game = _game.copyWith(winningLine: WinningLineModel.diagonalMain());
          notifyListeners();
          onLineAnimationReady?.call();
        }
      },
    );
  }

  navigate(BuildContext context) async {
    Map<String, dynamic>? route = await _deepLinkChannel.getPendingRoute();

    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    _deepLinkNavigator.navigate(navigator, route);
  }
}
