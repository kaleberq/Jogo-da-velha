import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/models/local_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';
import 'package:jogo_da_velha/extensions/player_turn_extension.dart';

class LocalGameViewModel extends ChangeNotifier {
  late LocalTicTacToeGameModel _game;
  static final Random _random = Random();
  LocalTicTacToeGameModel get game => _game;

  void _update(LocalTicTacToeGameModel newState) {
    _game = newState;
    notifyListeners();
  }

  LocalGameViewModel({required int maxRounds, required int timeLimitSeconds}) {
    _game = LocalTicTacToeGameModel(
      maxRounds: maxRounds,
      timeLimitSeconds: timeLimitSeconds,
    );
  }

  void setMaxRounds(int maxRounds) {
    _update(_game.copyWith(maxRounds: maxRounds));
  }

  void setTimeLimitSeconds(int timeLimitSeconds) {
    _update(_game.copyWith(timeLimitSeconds: timeLimitSeconds));
  }

  void reset() {
    _update(
      _game.copyWith(
        board: List.generate(
          3,
          (_) => List.generate(3, (_) => PlayerEnum.none),
        ),
        currentPlayer: PlayerEnum.x,
        clearWinner: true,
        clearWinningLine: true,
        isGameOver: false,
      ),
    );
  }

  void resetAll() {
    reset();

    _update(
      _game.copyWith(
        scoreX: 0,
        scoreO: 0,
        currentRound: 1,
        currentPlayer: _randomPlayer(),
      ),
    );
  }

  static PlayerEnum _randomPlayer() {
    return _random.nextBool() ? PlayerEnum.x : PlayerEnum.o;
  }

  void updateScore() {
    if (_game.winner == PlayerEnum.x) {
      _update(_game.copyWith(scoreX: _game.scoreX + 1));
    } else if (_game.winner == PlayerEnum.o) {
      _update(_game.copyWith(scoreO: _game.scoreO + 1));
    }
  }

  void nextRound() {
    final PlayerEnum? previousWinner = _game.winner;

    reset();

    if (previousWinner != null) {
      _update(
        _game.copyWith(
          currentPlayer: previousWinner,
          currentRound: _game.currentRound + 1,
        ),
      );
    } else {
      _update(_game.copyWith(currentRound: _game.currentRound + 1));
    }
  }

  bool get isAllRoundsFinished => _game.currentRound >= _game.maxRounds;

  PlayerEnum? get overallWinner {
    if (_game.scoreX > _game.scoreO) {
      return PlayerEnum.x;
    } else if (_game.scoreO > _game.scoreX) {
      return PlayerEnum.o;
    }
    return null;
  }

  bool makeMove(int row, int col) {
    if (_game.isGameOver || _game.board[row][col] != PlayerEnum.none) {
      return false;
    }

    _game.board[row][col] = _game.currentPlayer;

    final winningLineResult = _checkWinner(row, col);
    if (winningLineResult != null) {
      _update(
        _game.copyWith(
          winner: _game.currentPlayer,
          winningLine: winningLineResult,
          isGameOver: true,
        ),
      );
      return true;
    } else if (_checkDraw()) {
      _update(_game.copyWith(isGameOver: true));

      return true;
    } else {
      _update(_game.copyWith(currentPlayer: _game.currentPlayer.next));

      return true;
    }
  }

  WinningLineModel? _checkWinner(int row, int col) {
    if (_game.board[row][0] == _game.currentPlayer &&
        _game.board[row][1] == _game.currentPlayer &&
        _game.board[row][2] == _game.currentPlayer) {
      return WinningLineModel.horizontal(row);
    }

    if (_game.board[0][col] == _game.currentPlayer &&
        _game.board[1][col] == _game.currentPlayer &&
        _game.board[2][col] == _game.currentPlayer) {
      return WinningLineModel.vertical(col);
    }

    if (row == col &&
        _game.board[0][0] == _game.currentPlayer &&
        _game.board[1][1] == _game.currentPlayer &&
        _game.board[2][2] == _game.currentPlayer) {
      return WinningLineModel.diagonalMain();
    }

    if (row + col == 2 &&
        _game.board[0][2] == _game.currentPlayer &&
        _game.board[1][1] == _game.currentPlayer &&
        _game.board[2][0] == _game.currentPlayer) {
      return WinningLineModel.diagonalSecondary();
    }

    return null;
  }

  void endGameByTimeLimit() {
    if (!_game.isGameOver) {
      _update(
        _game.copyWith(isGameOver: true, winner: null, winningLine: null),
      );
    }
  }

  bool _checkDraw() {
    if (_game.winner != null) {
      return false;
    }

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_game.board[i][j] == PlayerEnum.none) {
          return false;
        }
      }
    }
    return true;
  }
}
