import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/direction_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/utils/deeplink_util.dart';

class SplashViewModel extends ChangeNotifier {
  final TicTacToeGameModel _ticTacToeGameState = TicTacToeGameModel();
  final SplashModel _splashState = SplashModel();
  final List<Map<DirectionEnum, int>> _diagonalPositions = [
    {DirectionEnum.row: 0, DirectionEnum.col: 0},
    {DirectionEnum.row: 1, DirectionEnum.col: 1},
    {DirectionEnum.row: 2, DirectionEnum.col: 2},
  ];
  TicTacToeGameModel get game => _ticTacToeGameState;
  SplashModel get state => _splashState;
  VoidCallback? onLineAnimationReady;

  @override
  void dispose() {
    _splashState.cancelTimer();
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
          _ticTacToeGameState.board[pos[DirectionEnum.row]!][pos[DirectionEnum
                  .col]!] =
              PlayerEnum.x;
          _splashState.incrementIndex();
          notifyListeners();
        } else {
          timer.cancel();
          _ticTacToeGameState.winningLine = WinningLineModel.diagonalMain();
          notifyListeners();
          onLineAnimationReady?.call();
        }
      },
    );
  }

  navigate(BuildContext context) async {
    Map<String, dynamic>? route = await DeepLinkUtil.getPendingRoute();

    if (!context.mounted) return;

    final navigator = Navigator.of(context);
    DeepLinkUtil.navigate(navigator, route);
  }
}
