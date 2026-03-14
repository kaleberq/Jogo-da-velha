import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';

/// Modelo base com os atributos comuns do jogo da velha (local e online).
abstract class TicTacToeGameModel {
  final List<List<PlayerEnum>> board;
  final PlayerEnum currentPlayer;
  final PlayerEnum? winner;
  final WinningLineModel? winningLine;
  final bool isGameOver;
  final int scoreX;
  final int scoreO;
  final int currentRound;
  final int maxRounds;

  const TicTacToeGameModel({
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
}
