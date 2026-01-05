import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/models/winning_line_model.dart';

class OnlineGameViewModel extends ChangeNotifier {
  late TicTacToeGameModel _game;
  final bool isHost;

  OnlineGameViewModel({required this.isHost, int? maxRounds}) {
    _game = TicTacToeGameModel(maxRounds: maxRounds);
    if (isHost) {
      _game.currentPlayer = PlayerEnum.x;
    } else {
      _game.currentPlayer = PlayerEnum.o;
    }
  }

  TicTacToeGameModel get game => _game;

  void setMaxRounds(int maxRounds) {
    _game.maxRounds = maxRounds;
    notifyListeners();
  }

  void reset() {
    _game.board = List.generate(
      3,
      (_) => List.generate(3, (_) => PlayerEnum.none),
    );
    _game.currentPlayer = isHost ? PlayerEnum.x : PlayerEnum.o;
    _game.winner = null;
    _game.winningLine = null;
    _game.isGameOver = false;
    notifyListeners();
  }

  void resetAll() {
    reset();
    _game.scoreX = 0;
    _game.scoreO = 0;
    _game.currentRound = 1;
    _game.currentPlayer = isHost ? PlayerEnum.x : PlayerEnum.o;
    notifyListeners();
  }

  void updateScore() {
    if (_game.winner == PlayerEnum.x) {
      _game.scoreX++;
    } else if (_game.winner == PlayerEnum.o) {
      _game.scoreO++;
    }
    notifyListeners();
  }

  void nextRound() {
    // Salva o vencedor do round anterior
    final PlayerEnum? previousWinner = _game.winner;

    _game.currentRound++;
    reset();

    // Se houve um vencedor, ele começa o próximo round
    if (previousWinner != null) {
      _game.currentPlayer = previousWinner;
    } else {
      // Se não houve vencedor, o host começa
      _game.currentPlayer = isHost ? PlayerEnum.x : PlayerEnum.o;
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
      _game.winner = _game.currentPlayer;
      _game.winningLine = winningLineResult;
      _game.isGameOver = true;
      notifyListeners();
      return true;
    }

    if (_checkDraw()) {
      _game.isGameOver = true;
      notifyListeners();
      return true;
    }

    _game.currentPlayer = _game.currentPlayer == PlayerEnum.x
        ? PlayerEnum.o
        : PlayerEnum.x;
    notifyListeners();
    return true;
  }

  // Fazer movimento de um jogador específico (usado em multiplayer)
  bool makeMoveWithPlayer(int row, int col, PlayerEnum player) {
    if (_game.isGameOver ||
        _game.board[row][col] != PlayerEnum.none ||
        player == PlayerEnum.none) {
      return false;
    }

    _game.board[row][col] = player;
    _game.currentPlayer = player == PlayerEnum.x ? PlayerEnum.o : PlayerEnum.x;

    final winningLineResult = _checkWinnerWithPlayer(row, col, player);
    if (winningLineResult != null) {
      _game.winner = player;
      _game.winningLine = winningLineResult;
      _game.isGameOver = true;
      notifyListeners();
      return true;
    }

    if (_checkDraw()) {
      _game.isGameOver = true;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return true;
  }

  WinningLineModel? _checkWinnerWithPlayer(
    int row,
    int col,
    PlayerEnum player,
  ) {
    // Verifica linha
    if (_game.board[row][0] == player &&
        _game.board[row][1] == player &&
        _game.board[row][2] == player) {
      return WinningLineModel.horizontal(row);
    }

    // Verifica coluna
    if (_game.board[0][col] == player &&
        _game.board[1][col] == player &&
        _game.board[2][col] == player) {
      return WinningLineModel.vertical(col);
    }

    // Verifica diagonal principal
    if (row == col &&
        _game.board[0][0] == player &&
        _game.board[1][1] == player &&
        _game.board[2][2] == player) {
      return WinningLineModel.diagonalMain();
    }

    // Verifica diagonal secundária
    if (row + col == 2 &&
        _game.board[0][2] == player &&
        _game.board[1][1] == player &&
        _game.board[2][0] == player) {
      return WinningLineModel.diagonalSecondary();
    }

    return null;
  }

  WinningLineModel? _checkWinner(int row, int col) {
    // Verifica linha
    if (_game.board[row][0] == _game.currentPlayer &&
        _game.board[row][1] == _game.currentPlayer &&
        _game.board[row][2] == _game.currentPlayer) {
      return WinningLineModel.horizontal(row);
    }

    // Verifica coluna
    if (_game.board[0][col] == _game.currentPlayer &&
        _game.board[1][col] == _game.currentPlayer &&
        _game.board[2][col] == _game.currentPlayer) {
      return WinningLineModel.vertical(col);
    }

    // Verifica diagonal principal
    if (row == col &&
        _game.board[0][0] == _game.currentPlayer &&
        _game.board[1][1] == _game.currentPlayer &&
        _game.board[2][2] == _game.currentPlayer) {
      return WinningLineModel.diagonalMain();
    }

    // Verifica diagonal secundária
    if (row + col == 2 &&
        _game.board[0][2] == _game.currentPlayer &&
        _game.board[1][1] == _game.currentPlayer &&
        _game.board[2][0] == _game.currentPlayer) {
      return WinningLineModel.diagonalSecondary();
    }

    return null;
  }

  bool _checkDraw() {
    // Primeiro verifica se há um vencedor - se houver, não é empate
    if (_game.winner != null) {
      return false;
    }

    // Verifica se todas as células estão preenchidas
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
