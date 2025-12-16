enum Player { x, o, none }

class TicTacToeGame {
  List<List<Player>> board;
  Player currentPlayer;
  Player? winner;
  bool isGameOver;

  TicTacToeGame()
    : board = List.generate(3, (_) => List.generate(3, (_) => Player.none)),
      currentPlayer = Player.x,
      winner = null,
      isGameOver = false;

  void reset() {
    board = List.generate(3, (_) => List.generate(3, (_) => Player.none));
    currentPlayer = Player.x;
    winner = null;
    isGameOver = false;
  }

  bool makeMove(int row, int col) {
    if (isGameOver || board[row][col] != Player.none) {
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

    currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
    return true;
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
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }
}
