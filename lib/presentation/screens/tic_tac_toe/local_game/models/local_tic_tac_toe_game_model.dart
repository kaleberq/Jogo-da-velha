import 'dart:math';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';

class LocalTicTacToeGameModel extends TicTacToeGameModel {
  static final Random _random = Random();
  final int timeLimitSeconds;

  LocalTicTacToeGameModel({int? maxRounds, int? timeLimitSeconds})
    : this._internal(
        board: List.generate(
          3,
          (_) => List.generate(3, (_) => PlayerEnum.none),
        ),
        currentPlayer: _random.nextBool() ? PlayerEnum.x : PlayerEnum.o,
        winner: null,
        winningLine: null,
        isGameOver: false,
        scoreX: 0,
        scoreO: 0,
        currentRound: 1,
        maxRounds: maxRounds ?? 5,
        timeLimitSeconds: timeLimitSeconds ?? 10,
      );

  LocalTicTacToeGameModel._internal({
    required List<List<PlayerEnum>> board,
    required PlayerEnum currentPlayer,
    required PlayerEnum? winner,
    required WinningLineModel? winningLine,
    required bool isGameOver,
    required int scoreX,
    required int scoreO,
    required int currentRound,
    required int maxRounds,
    required this.timeLimitSeconds,
  }) : super(
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
