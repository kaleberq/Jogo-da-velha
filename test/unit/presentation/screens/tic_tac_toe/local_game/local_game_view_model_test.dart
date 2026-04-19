import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/local_game_view_model.dart';

void main() {
  group('LocalGameViewModel', () {
    test('makeMove marks board and switches player', () {
      final viewModel = LocalGameViewModel(maxRounds: 5, timeLimitSeconds: 10);
      final initialPlayer = viewModel.game.currentPlayer;

      final success = viewModel.makeMove(0, 0);

      expect(success, isTrue);
      expect(viewModel.game.board[0][0], initialPlayer);
      expect(viewModel.game.currentPlayer, isNot(initialPlayer));
      expect(viewModel.game.isGameOver, isFalse);
    });

    test('returns false when trying to play occupied cell', () {
      final viewModel = LocalGameViewModel(maxRounds: 5, timeLimitSeconds: 10);

      viewModel.makeMove(0, 0);
      final secondTry = viewModel.makeMove(0, 0);

      expect(secondTry, isFalse);
    });

    test('detects row winner and sets winning line', () {
      final viewModel = LocalGameViewModel(maxRounds: 5, timeLimitSeconds: 10);
      final winner = viewModel.game.currentPlayer;

      // Force deterministic row win for current player.
      viewModel.game.board[0][0] = winner;
      viewModel.game.board[0][1] = winner;
      viewModel.game.board[0][2] = PlayerEnum.none;
      viewModel.game.board[1][0] = PlayerEnum.none;
      viewModel.game.board[1][1] = PlayerEnum.none;
      viewModel.game.board[1][2] = PlayerEnum.none;
      viewModel.game.board[2][0] = PlayerEnum.none;
      viewModel.game.board[2][1] = PlayerEnum.none;
      viewModel.game.board[2][2] = PlayerEnum.none;

      final success = viewModel.makeMove(0, 2);

      expect(success, isTrue);
      expect(viewModel.game.winner, winner);
      expect(viewModel.game.isGameOver, isTrue);
      expect(viewModel.game.winningLine?.type, WinningLineEnum.horizontal);
      expect(viewModel.game.winningLine?.index, 0);
    });

    test('nextRound increments round and keeps previous winner as starter', () {
      final viewModel = LocalGameViewModel(maxRounds: 5, timeLimitSeconds: 10);
      final winner = PlayerEnum.x;

      viewModel.game.board[0][0] = winner;
      viewModel.game.board[0][1] = winner;
      viewModel.game.board[0][2] = PlayerEnum.none;
      viewModel.game.currentPlayer == winner;
      viewModel.makeMove(0, 2);

      viewModel.nextRound();

      expect(viewModel.game.currentRound, 2);
      expect(viewModel.game.currentPlayer, winner);
      expect(viewModel.game.winner, isNull);
      expect(viewModel.game.isGameOver, isFalse);
    });
  });
}
