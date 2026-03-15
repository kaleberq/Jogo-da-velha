import 'dart:async';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';

class SplashModel extends TicTacToeGameModel {
  final int currentIndex;
  final Timer? boardAnimationTimer;
  final bool hasStartedBoardAnimation;

  SplashModel({
    List<List<PlayerEnum>>? board,
    PlayerEnum? currentPlayer,
    super.winner,
    super.winningLine,
    bool? isGameOver,
    int? scoreX,
    int? scoreO,
    int? currentRound,
    int? maxRounds,
    this.currentIndex = 0,
    this.boardAnimationTimer,
    this.hasStartedBoardAnimation = false,
  }) : super(
         board:
             board ??
             List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
         currentPlayer: PlayerEnum.x,
         isGameOver: isGameOver ?? false,
         scoreX: scoreX ?? 0,
         scoreO: scoreO ?? 0,
         currentRound: currentRound ?? 1,
         maxRounds: maxRounds ?? 5,
       );

  SplashModel copyWith({
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
    int? currentIndex,
    Timer? boardAnimationTimer,
    bool clearBoardAnimationTimer = false,
    bool? hasStartedBoardAnimation,
  }) {
    return SplashModel(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: clearWinner ? null : (winner ?? this.winner),
      winningLine: clearWinningLine ? null : (winningLine ?? this.winningLine),
      isGameOver: isGameOver ?? this.isGameOver,
      scoreX: scoreX ?? this.scoreX,
      scoreO: scoreO ?? this.scoreO,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds ?? this.maxRounds,
      currentIndex: currentIndex ?? this.currentIndex,
      boardAnimationTimer: clearBoardAnimationTimer
          ? null
          : (boardAnimationTimer ?? this.boardAnimationTimer),
      hasStartedBoardAnimation:
          hasStartedBoardAnimation ?? this.hasStartedBoardAnimation,
    );
  }
}
