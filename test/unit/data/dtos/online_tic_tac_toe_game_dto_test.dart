import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';

void main() {
  group('OnlineTicTacToeGameDTO', () {
    test('toJson and fromJson keep data consistency', () {
      const dto = OnlineTicTacToeGameDTO(
        board: [
          ['x', 'o', 'none'],
          ['none', 'x', 'o'],
          ['o', 'none', 'x'],
        ],
        currentPlayer: 'x',
        winner: 'x',
        winningLine: {'type': 'row', 'index': 0},
        isGameOver: true,
        scoreX: 2,
        scoreO: 1,
        currentRound: 3,
        maxRounds: 5,
      );

      final json = dto.toJson();
      final parsed = OnlineTicTacToeGameDTO.fromJson(json);

      expect(parsed.board, dto.board);
      expect(parsed.currentPlayer, dto.currentPlayer);
      expect(parsed.winner, dto.winner);
      expect(parsed.winningLine, dto.winningLine);
      expect(parsed.isGameOver, dto.isGameOver);
      expect(parsed.scoreX, dto.scoreX);
      expect(parsed.scoreO, dto.scoreO);
      expect(parsed.currentRound, dto.currentRound);
      expect(parsed.maxRounds, dto.maxRounds);
    });

    test('fromJson handles null winningLine', () {
      final parsed = OnlineTicTacToeGameDTO.fromJson({
        'board': [
          ['none', 'none', 'none'],
          ['none', 'none', 'none'],
          ['none', 'none', 'none'],
        ],
        'currentPlayer': 'o',
        'winner': null,
        'winningLine': null,
        'isGameOver': false,
        'scoreX': 0,
        'scoreO': 0,
        'currentRound': 1,
        'maxRounds': 3,
      });

      expect(parsed.winningLine, isNull);
      expect(parsed.winner, isNull);
      expect(parsed.currentPlayer, 'o');
    });
  });
}
