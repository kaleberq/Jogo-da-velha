import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/data/models/network_connection_model.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/data/repositories/game_repository.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';

class OnlineGameViewModel extends ChangeNotifier {
  late TicTacToeGameModel _game;
  final bool isHost;
  final IGameRepository _gameRepository;

  // Estado da conexão gerenciado pelo ViewModel
  final NetworkConnectionModel _connectionState = NetworkConnectionModel();

  // Callbacks para a UI
  VoidCallback? onOpponentDisconnected;
  Function(String)? onError;
  Function(int, int, PlayerEnum)? onMoveReceived;
  VoidCallback? onResetReceived;
  VoidCallback? onNextRoundReceived;
  Function(int)? onConfigReceived;

  OnlineGameViewModel({required this.isHost, int? maxRounds})
    : _gameRepository = GameRepository() {
    _game = TicTacToeGameModel(maxRounds: maxRounds);
    if (isHost) {
      _game.currentPlayer = PlayerEnum.x;
    } else {
      _game.currentPlayer = PlayerEnum.o;
    }
    _setupNetworkCallbacks();
  }

  TicTacToeGameModel get game => _game;

  void _setupNetworkCallbacks() {
    _gameRepository.onMessageReceived = _handleNetworkMessage;
    _gameRepository.onConnectionStatusChanged = (statusString) {
      final status = ConnectionStatusEnum.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => ConnectionStatusEnum.disconnected,
      );
      _updateConnectionStatus(status);

      if (status == ConnectionStatusEnum.disconnected) {
        onOpponentDisconnected?.call();
      }
    };
    _gameRepository.onError = (error) {
      _connectionState.errorMessage = error;
      _connectionState.status = ConnectionStatusEnum.error;
      notifyListeners();
      onError?.call(error);
    };
  }

  void _updateConnectionStatus(ConnectionStatusEnum status) {
    _connectionState.status = status;
    notifyListeners();
  }

  void _handleNetworkMessage(String message) {
    if (message == 'DISCONNECTED') {
      onOpponentDisconnected?.call();
      return;
    }

    if (message == 'SERVER_CONNECTED' ||
        message == 'CLIENT_CONNECTED' ||
        message == 'CONNECTED') {
      return;
    }

    try {
      final data = jsonDecode(message);
      final type = data['type'] as String;

      switch (type) {
        case 'move':
          final row = data['row'] as int;
          final col = data['col'] as int;
          final playerStr = data['player'] as String;
          final player = playerStr == 'x' ? PlayerEnum.x : PlayerEnum.o;
          onMoveReceived?.call(row, col, player);
          break;
        case 'reset':
          onResetReceived?.call();
          break;
        case 'nextRound':
          onNextRoundReceived?.call();
          break;
        case 'config':
          final maxRounds = data['maxRounds'] as int;
          onConfigReceived?.call(maxRounds);
          break;
      }
    } catch (e) {
      // Ignora mensagens que não são JSON válido
    }
  }

  // Métodos para enviar eventos de rede
  void sendMove(int row, int col, PlayerEnum player) {
    _gameRepository.sendMove(row, col, player.value);
  }

  void sendReset() {
    _gameRepository.sendReset();
  }

  void sendNextRound() {
    _gameRepository.sendNextRound();
  }

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
    final PlayerEnum? previousWinner = _game.winner;

    _game.currentRound++;
    reset();

    if (previousWinner != null) {
      _game.currentPlayer = previousWinner;
    } else {
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
    if (_game.board[row][0] == player &&
        _game.board[row][1] == player &&
        _game.board[row][2] == player) {
      return WinningLineModel.horizontal(row);
    }

    if (_game.board[0][col] == player &&
        _game.board[1][col] == player &&
        _game.board[2][col] == player) {
      return WinningLineModel.vertical(col);
    }

    if (row == col &&
        _game.board[0][0] == player &&
        _game.board[1][1] == player &&
        _game.board[2][2] == player) {
      return WinningLineModel.diagonalMain();
    }

    if (row + col == 2 &&
        _game.board[0][2] == player &&
        _game.board[1][1] == player &&
        _game.board[2][0] == player) {
      return WinningLineModel.diagonalSecondary();
    }

    return null;
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

  @override
  void dispose() {
    _gameRepository.disconnect();
    super.dispose();
  }
}
