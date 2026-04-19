import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/data/dtos/online_tic_tac_toe_game_dto.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';
import 'package:jogo_da_velha/domain/models/online_tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/models/winning_line_model.dart';

void main() {
  group('OnlineTicTacToeGameModel', () {
    test('creates default state', () {
      final model = OnlineTicTacToeGameModel();

      expect(model.board.length, 3);
      expect(model.board.every((row) => row.length == 3), isTrue);
      expect(model.currentPlayer, PlayerEnum.x);
      expect(model.maxRounds, 5);
      expect(model.winner, isNull);
      expect(model.winningLine, isNull);
      expect(model.isGameOver, isFalse);
    });

    test('fromDto maps board and winning line correctly', () {
      const dto = OnlineTicTacToeGameDTO(
        board: [
          ['x', 'o', 'none'],
          ['none', 'x', 'o'],
          ['none', 'none', 'x'],
        ],
        currentPlayer: 'o',
        winner: 'x',
        winningLine: {'type': 'diagonalMain', 'index': null},
        isGameOver: true,
        scoreX: 2,
        scoreO: 1,
        currentRound: 3,
        maxRounds: 7,
      );

      final model = OnlineTicTacToeGameModel.fromDto(dto);

      expect(model.board[0][0], PlayerEnum.x);
      expect(model.board[0][1], PlayerEnum.o);
      expect(model.board[0][2], PlayerEnum.none);
      expect(model.currentPlayer, PlayerEnum.o);
      expect(model.winner, PlayerEnum.x);
      expect(model.winningLine?.type, WinningLineEnum.diagonalMain);
      expect(model.isGameOver, isTrue);
      expect(model.scoreX, 2);
      expect(model.scoreO, 1);
      expect(model.currentRound, 3);
      expect(model.maxRounds, 7);
    });

    test('toDto maps enum values back to DTO payload', () {
      final model = OnlineTicTacToeGameModel.fromValues(
        board: [
          [PlayerEnum.x, PlayerEnum.o, PlayerEnum.none],
          [PlayerEnum.none, PlayerEnum.x, PlayerEnum.o],
          [PlayerEnum.none, PlayerEnum.none, PlayerEnum.x],
        ],
        currentPlayer: PlayerEnum.o,
        winner: PlayerEnum.x,
        winningLine: WinningLineModel.diagonalMain(),
        isGameOver: true,
        scoreX: 3,
        scoreO: 2,
        currentRound: 5,
        maxRounds: 9,
      );

      final dto = model.toDto();

      expect(dto.board[0][0], 'x');
      expect(dto.board[0][1], 'o');
      expect(dto.board[0][2], 'none');
      expect(dto.currentPlayer, 'o');
      expect(dto.winner, 'x');
      expect(dto.winningLine?['type'], 'diagonalMain');
      expect(dto.isGameOver, isTrue);
      expect(dto.scoreX, 3);
      expect(dto.scoreO, 2);
      expect(dto.currentRound, 5);
      expect(dto.maxRounds, 9);
    });

    test('copyWith can clear winner and winning line', () {
      final base = OnlineTicTacToeGameModel.fromValues(
        board: List.generate(3, (_) => List.generate(3, (_) => PlayerEnum.none)),
        currentPlayer: PlayerEnum.x,
        winner: PlayerEnum.o,
        winningLine: WinningLineModel.horizontal(0),
        isGameOver: true,
        scoreX: 0,
        scoreO: 1,
        currentRound: 2,
        maxRounds: 5,
      );

      final updated = base.copyWith(
        clearWinner: true,
        clearWinningLine: true,
        isGameOver: false,
      );

      expect(updated.winner, isNull);
      expect(updated.winningLine, isNull);
      expect(updated.isGameOver, isFalse);
      expect(updated.currentPlayer, PlayerEnum.x);
    });
  });
}
