import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/extensions/player_turn_extension.dart';

class LocalGameViewModel extends ChangeNotifier {
  late TicTacToeGameModel _game;
  static final Random _random = Random();
  TicTacToeGameModel get game => _game;

  LocalGameViewModel({required int maxRounds, required int timeLimitSeconds}) {
    _game = TicTacToeGameModel(
      maxRounds: maxRounds,
      timeLimitSeconds: timeLimitSeconds,
    );
  }

  void setMaxRounds(int maxRounds) {
    _game = _game.copyWith(maxRounds: maxRounds);
    notifyListeners();
  }

  void setTimeLimitSeconds(int timeLimitSeconds) {
    _game = _game.copyWith(timeLimitSeconds: timeLimitSeconds);
    notifyListeners();
  }

  void reset() {
    _game = _game.copyWith(
      board: List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      currentPlayer: PlayerEnum.x,
      winner: null,
      winningLine: null,
      isGameOver: false,
    );

    notifyListeners();
  }

  void resetAll() {
    reset();

    _game = _game.copyWith(
      scoreX: 0,
      scoreO: 0,
      currentRound: 1,
      currentPlayer: _randomPlayer(),
    );

    notifyListeners();
  }

  static PlayerEnum _randomPlayer() {
    return _random.nextBool() ? PlayerEnum.x : PlayerEnum.o;
  }

  void updateScore() {
    if (_game.winner == PlayerEnum.x) {
      _game = _game.copyWith(scoreX: _game.scoreX + 1);
    } else if (_game.winner == PlayerEnum.o) {
      _game = _game.copyWith(scoreO: _game.scoreO + 1);
    }
    notifyListeners();
  }

  void nextRound() {
    final PlayerEnum? previousWinner = _game.winner;

    reset();

    if (previousWinner != null) {
      _game = _game.copyWith(
        currentPlayer: previousWinner,
        currentRound: _game.currentRound + 1,
      );
    } else {
      _game = _game.copyWith(currentRound: _game.currentRound + 1);
    }
    notifyListeners();
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
      _game = _game.copyWith(
        winner: _game.currentPlayer,
        winningLine: winningLineResult,
        isGameOver: true,
      );
      notifyListeners();
      return true;
    } else if (_checkDraw()) {
      _game = _game.copyWith(isGameOver: true);

      notifyListeners();
      return true;
    } else {
      _game = _game.copyWith(currentPlayer: _game.currentPlayer.next);

      notifyListeners();
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
      _game = _game.copyWith(isGameOver: true, winner: null, winningLine: null);
      notifyListeners();
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
