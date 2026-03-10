import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/winning_line_model.dart';

class OnlineTicTacToeGameModel {
  final List<List<PlayerEnum>> board;
  final PlayerEnum currentPlayer;
  final PlayerEnum? winner;
  final WinningLineModel? winningLine;
  final bool isGameOver;
  final int scoreX;
  final int scoreO;
  final int currentRound;
  final int maxRounds;

  OnlineTicTacToeGameModel({int? maxRounds})
    : board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      currentPlayer = PlayerEnum.x,
      winner = null,
      winningLine = null,
      isGameOver = false,
      scoreX = 0,
      scoreO = 0,
      currentRound = 1,
      maxRounds = maxRounds ?? 5;

  OnlineTicTacToeGameModel._internal({
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.winningLine,
    required this.isGameOver,
    required this.scoreX,
    required this.scoreO,
    required this.currentRound,
    required this.maxRounds,
  });

  /// Construtor para reconstruir o estado a partir de valores.
  factory OnlineTicTacToeGameModel.fromValues({
    required List<List<PlayerEnum>> board,
    required PlayerEnum currentPlayer,
    PlayerEnum? winner,
    WinningLineModel? winningLine,
    required bool isGameOver,
    required int scoreX,
    required int scoreO,
    required int currentRound,
    required int maxRounds,
  }) {
    return OnlineTicTacToeGameModel._internal(
      board: board,
      currentPlayer: currentPlayer,
      winner: winner,
      winningLine: winningLine,
      isGameOver: isGameOver,
      scoreX: scoreX,
      scoreO: scoreO,
      currentRound: currentRound,
      maxRounds: maxRounds,
    );
  }

  OnlineTicTacToeGameModel copyWith({
    List<List<PlayerEnum>>? board,
    PlayerEnum? currentPlayer,
    PlayerEnum? winner,
    WinningLineModel? winningLine,
    bool clearWinner = false,
    bool clearWinningLine = false,
    bool? isGameOver,
    int? scoreX,
    int? scoreO,
    int? currentRound,
    int? maxRounds,
  }) {
    return OnlineTicTacToeGameModel._internal(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: clearWinner ? null : (winner ?? this.winner),
      winningLine: clearWinningLine ? null : (winningLine ?? this.winningLine),
      isGameOver: isGameOver ?? this.isGameOver,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
    );
  }
}
