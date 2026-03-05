import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jogo_da_velha/data/models/network_connection_model.dart';
import 'package:jogo_da_velha/domain/enums/connection_status_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';
import 'package:jogo_da_velha/domain/interfaces/repositories/game_repository_interface.dart';

/// ViewModel para jogo online
/// Constructor Injection: recebe IGameRepository via construtor
class OnlineGameViewModel extends ChangeNotifier {
  late TicTacToeGameModel _game;
  final PlayerRole playerRole;
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
  TicTacToeGameModel get game => _game;

  void _update(TicTacToeGameModel newState) {
    _game = newState;
    notifyListeners();
  }

  PlayerEnum get _currentPlayer =>
      playerRole.isHost ? PlayerEnum.x : PlayerEnum.o;

  /// Jogador que o usuário local está usando (X ou O).
  PlayerEnum get myPlayer => _currentPlayer;

  /// Constructor Injection: IGameRepository é obrigatório via construtor
  OnlineGameViewModel({
    required this.playerRole,
    required IGameRepository gameRepository,
    int? maxRounds,
  }) : _gameRepository = gameRepository {
    _game = TicTacToeGameModel(maxRounds: maxRounds);
    _update(_game.copyWith(currentPlayer: _currentPlayer));
    _setupNetworkCallbacks();
  }

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

          // Converte String de volta para PlayerEnum usando byName
          final player = PlayerEnum.values.byName(playerStr);

          if (player != PlayerEnum.none) {
            onMoveReceived?.call(row, col, player);
          }
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
  void sendMove({
    required int row,
    required int col,
    required PlayerEnum player,
  }) {
    _gameRepository.sendMove(row: row, col: col, player: player);
  }

  void sendReset() {
    _gameRepository.sendReset();
  }

  void sendNextRound() {
    _gameRepository.sendNextRound();
  }

  void setMaxRounds(int maxRounds) {
    _update(_game.copyWith(maxRounds: maxRounds));
  }

  void reset() {
    _update(
      _game.copyWith(
        board: List.generate(
          3,
          (_) => List.generate(3, (_) => PlayerEnum.none),
        ),
        currentPlayer: _currentPlayer,
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
        currentPlayer: _currentPlayer,
      ),
    );
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
      _update(
        _game.copyWith(
          currentPlayer: _currentPlayer,
          currentRound: _game.currentRound + 1,
        ),
      );
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
      _update(_game.copyWith(currentPlayer: _currentPlayer));
      return true;
    }
  }

  bool makeMoveWithPlayer(int row, int col, PlayerEnum player) {
    if (_game.isGameOver ||
        _game.board[row][col] != PlayerEnum.none ||
        player == PlayerEnum.none) {
      return false;
    }

    _game.board[row][col] = player;

    final winningLineResult = _checkWinnerWithPlayer(row, col, player);
    if (winningLineResult != null) {
      _update(
        _game.copyWith(
          winner: player,
          winningLine: winningLineResult,
          isGameOver: true,
          currentPlayer: _currentPlayer,
        ),
      );
      return true;
    } else if (_checkDraw()) {
      _update(_game.copyWith(isGameOver: true, currentPlayer: _currentPlayer));
      return true;
    } else {
      _update(_game);
      return true;
    }
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
