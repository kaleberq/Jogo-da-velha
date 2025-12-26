import 'dart:math';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class TicTacToeGameViewModel {
  static final Random _random = Random();
  List<List<PlayerEnum>> board;
  PlayerEnum currentPlayer;
  PlayerEnum? winner;
  bool isGameOver;
  int scoreX;
  int scoreO;
  int currentRound;
  int maxRounds;

  TicTacToeGameViewModel({int? maxRounds})
    : board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      currentPlayer = _randomPlayer(),
      winner = null,
      isGameOver = false,
      scoreX = 0,
      scoreO = 0,
      currentRound = 1,
      maxRounds = maxRounds ?? 5;

  void reset() {
    board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none));
    currentPlayer = PlayerEnum.x;
    winner = null;
    isGameOver = false;
  }

  void resetAll() {
    reset();
    scoreX = 0;
    scoreO = 0;
    currentRound = 1;
    currentPlayer = _randomPlayer();
  }

  static PlayerEnum _randomPlayer() {
    return _random.nextBool() ? PlayerEnum.x : PlayerEnum.o;
  }

  void updateScore() {
    if (winner == PlayerEnum.x) {
      scoreX++;
    } else if (winner == PlayerEnum.o) {
      scoreO++;
    }
  }

  void nextRound() {
    // Salva o vencedor do round anterior
    final PlayerEnum? previousWinner = winner;

    currentRound++;
    reset();

    // Se houve um vencedor, ele começa o próximo round
    if (previousWinner != null) {
      currentPlayer = previousWinner;
    }
  }

  bool get isAllRoundsFinished => currentRound >= maxRounds;

  PlayerEnum? get overallWinner {
    if (scoreX > scoreO) {
      return PlayerEnum.x;
    } else if (scoreO > scoreX) {
      return PlayerEnum.o;
    }
    return null;
  }

  bool makeMove(int row, int col) {
    if (isGameOver || board[row][col] != PlayerEnum.none) {
      return false;
    }

    board[row][col] = currentPlayer;

    if (_checkWinner(row, col)) {
      winner = currentPlayer;
      isGameOver = true;
      return true;
    }

    if (_checkDraw()) {
      isGameOver = true;
      return true;
    }

    currentPlayer = currentPlayer == PlayerEnum.x ? PlayerEnum.o : PlayerEnum.x;
    return true;
  }

  // Fazer movimento de um jogador específico (usado em multiplayer)
  bool makeMoveWithPlayer(int row, int col, PlayerEnum player) {
    if (isGameOver ||
        board[row][col] != PlayerEnum.none ||
        player == PlayerEnum.none) {
      return false;
    }

    board[row][col] = player;
    currentPlayer = player == PlayerEnum.x ? PlayerEnum.o : PlayerEnum.x;

    if (_checkWinnerWithPlayer(row, col, player)) {
      winner = player;
      isGameOver = true;
      return true;
    }

    if (_checkDraw()) {
      isGameOver = true;
      return true;
    }

    return true;
  }

  bool _checkWinnerWithPlayer(int row, int col, PlayerEnum player) {
    // Verifica linha
    if (board[row][0] == player &&
        board[row][1] == player &&
        board[row][2] == player) {
      return true;
    }

    // Verifica coluna
    if (board[0][col] == player &&
        board[1][col] == player &&
        board[2][col] == player) {
      return true;
    }

    // Verifica diagonal principal
    if (row == col &&
        board[0][0] == player &&
        board[1][1] == player &&
        board[2][2] == player) {
      return true;
    }

    // Verifica diagonal secundária
    if (row + col == 2 &&
        board[0][2] == player &&
        board[1][1] == player &&
        board[2][0] == player) {
      return true;
    }

    return false;
  }

  bool _checkWinner(int row, int col) {
    // Verifica linha
    if (board[row][0] == currentPlayer &&
        board[row][1] == currentPlayer &&
        board[row][2] == currentPlayer) {
      return true;
    }

    // Verifica coluna
    if (board[0][col] == currentPlayer &&
        board[1][col] == currentPlayer &&
        board[2][col] == currentPlayer) {
      return true;
    }

    // Verifica diagonal principal
    if (row == col &&
        board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      return true;
    }

    // Verifica diagonal secundária
    if (row + col == 2 &&
        board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      return true;
    }

    return false;
  }

  bool _checkDraw() {
    // Primeiro verifica se há um vencedor - se houver, não é empate
    if (winner != null) {
      return false;
    }

    // Verifica se todas as células estão preenchidas
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == PlayerEnum.none) {
          return false;
        }
      }
    }
    return true;
  }
}
