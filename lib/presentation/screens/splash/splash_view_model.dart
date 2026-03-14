import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/direction_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';
import 'package:jogo_da_velha/presentation/screens/splash/models/splash_model.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_data_source_channel_interface.dart';
import 'package:jogo_da_velha/domain/interfaces/channels/deep_links/deep_link_navigator_interface.dart';

class SplashViewModel extends ChangeNotifier {
  final List<Map<DirectionEnum, int>> _diagonalPositions = [
    {DirectionEnum.row: 0, DirectionEnum.col: 0},
    {DirectionEnum.row: 1, DirectionEnum.col: 1},
    {DirectionEnum.row: 2, DirectionEnum.col: 2},
  ];
  late SplashModel _game;
  SplashModel get game => _game;

  VoidCallback? onLineAnimationReady;

  late final IDeepLinkNavigator _deepLinkNavigator;
  late final IDeepLinkDataSourceChannel _deepLinkChannel;

  SplashViewModel({
    required IDeepLinkDataSourceChannel deeplinkDataSourceChannel,
    required IDeepLinkNavigator navigator,
    required SplashModel ticTacToeGame,
  }) {
    _deepLinkChannel = deeplinkDataSourceChannel;
    _deepLinkNavigator = navigator;
    _game = ticTacToeGame;
  }

  @override
  void dispose() {
    _game.boardAnimationTimer?.cancel();
    _game = _game.copyWith(clearBoardAnimationTimer: true);
    super.dispose();
  }

  void _update(SplashModel newState) {
    _game = newState;
    notifyListeners();
  }

  void startBoardAnimation() {
    if (_game.hasStartedBoardAnimation) return;

    final timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (_game.currentIndex < _diagonalPositions.length) {
        final pos = _diagonalPositions[_game.currentIndex];
        final row = pos[DirectionEnum.row]!;
        final col = pos[DirectionEnum.col]!;
        _game.board[row][col] = PlayerEnum.x;
        _update(_game.copyWith(currentIndex: _game.currentIndex + 1));
      } else {
        t.cancel();
        _update(_game.copyWith(winningLine: WinningLineModel.diagonalMain()));
        onLineAnimationReady?.call();
      }
    });
    _update(
      _game.copyWith(
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
