import 'dart:math';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/winning_line_model.dart';

class TicTacToeGameModel {
  static final Random _random = Random();
  List<List<PlayerEnum>> board;
  PlayerEnum currentPlayer;
  PlayerEnum? winner;
  WinningLineModel? winningLine;
  bool isGameOver;
  int scoreX;
  int scoreO;
  int currentRound;
  int maxRounds;

  TicTacToeGameModel({int? maxRounds})
    : board = List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
      currentPlayer = _random.nextBool() ? PlayerEnum.x : PlayerEnum.o,
      winner = null,
      winningLine = null,
      isGameOver = false,
      scoreX = 0,
      scoreO = 0,
      currentRound = 1,
      maxRounds = maxRounds ?? 5;
}
