import 'dart:math';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';

class LocalTicTacToeGameModel {
  static final Random _random = Random();
  final List<List<PlayerEnum>> board;
  final PlayerEnum currentPlayer;
  final PlayerEnum? winner;
  final WinningLineModel? winningLine;
  final bool isGameOver;
  final int scoreX;
  final int scoreO;
  final int currentRound;
  final int maxRounds;
  final int timeLimitSeconds;

  LocalTicTacToeGameModel({int? maxRounds, int? timeLimitSeconds})
    : board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      // Para jogo local, o primeiro jogador pode ser aleatório
      currentPlayer = _random.nextBool() ? PlayerEnum.x : PlayerEnum.o,
      winner = null,
      winningLine = null,
      isGameOver = false,
      scoreX = 0,
      scoreO = 0,
      currentRound = 1,
      maxRounds = maxRounds ?? 5,
      timeLimitSeconds = timeLimitSeconds ?? 10;

  LocalTicTacToeGameModel._internal({
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.winningLine,
    required this.isGameOver,
    required this.scoreX,
    required this.scoreO,
    required this.currentRound,
    required this.maxRounds,
    required this.timeLimitSeconds,
  });

  LocalTicTacToeGameModel copyWith({
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
    int? timeLimitSeconds,
  }) {
    return LocalTicTacToeGameModel._internal(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: clearWinner ? null : (winner ?? this.winner),
      winningLine: clearWinningLine ? null : (winningLine ?? this.winningLine),
      isGameOver: isGameOver ?? this.isGameOver,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
    );
  }
}
