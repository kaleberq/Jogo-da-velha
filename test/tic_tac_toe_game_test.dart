import 'package:flutter_test/flutter_test.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/tic_tac_toe_game_view_model.dart';

void main() {
  group('TicTacToeGame', () {
    late TicTacToeGameViewModel game;

    setUp(() {
      game = TicTacToeGameViewModel(maxRounds: 5);
      // Define X como jogador inicial para consistência nos testes
      game.currentPlayer = PlayerEnum.x;
    });

    group('Inicialização', () {
      test('deve inicializar com tabuleiro vazio', () {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            expect(game.board[i][j], PlayerEnum.none);
          }
        }
      });

      test('deve inicializar com um jogador aleatório (X ou O)', () {
        // Cria um novo jogo para testar a aleatoriedade
        final newGame = TicTacToeGameViewModel(maxRounds: 5);
        expect(
          newGame.currentPlayer == PlayerEnum.x ||
              newGame.currentPlayer == PlayerEnum.o,
          true,
        );
      });

      test('deve inicializar sem vencedor', () {
        expect(game.winner, isNull);
      });

      test('deve inicializar com jogo não finalizado', () {
        expect(game.isGameOver, false);
      });

      test('deve inicializar com pontuação zerada', () {
        expect(game.scoreX, 0);
        expect(game.scoreO, 0);
      });

      test('deve inicializar no round 1', () {
        expect(game.currentRound, 1);
      });
    });

    group('reset', () {
      test('deve resetar o tabuleiro', () {
        game.makeMove(0, 0);
        game.makeMove(1, 1);
        game.reset();

        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            expect(game.board[i][j], PlayerEnum.none);
          }
        }
      });

      test('deve resetar o jogador atual para X', () {
        game.makeMove(0, 0);
        game.reset();
        expect(game.currentPlayer, PlayerEnum.x);
      });

      test('deve resetar o vencedor', () {
        // Simula uma vitória
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence

        expect(game.winner, PlayerEnum.x);
        game.reset();
        expect(game.winner, isNull);
      });

      test('deve resetar o estado de jogo finalizado', () {
        // Simula um empate
        game.makeMove(0, 0); // X
        game.makeMove(0, 1); // O
        game.makeMove(0, 2); // X
        game.makeMove(1, 1); // O
        game.makeMove(1, 0); // X
        game.makeMove(1, 2); // O
        game.makeMove(2, 0); // X
        game.makeMove(2, 2); // O
        game.makeMove(2, 1); // X - empate

        expect(game.isGameOver, true);
        game.reset();
        expect(game.isGameOver, false);
      });

      test('não deve resetar pontuação e round', () {
        game.scoreX = 2;
        game.scoreO = 1;
        game.currentRound = 3;
        game.reset();

        expect(game.scoreX, 2);
        expect(game.scoreO, 1);
        expect(game.currentRound, 3);
      });
    });

    group('resetAll', () {
      test('deve resetar tudo incluindo pontuação e round', () {
        game.scoreX = 2;
        game.scoreO = 1;
        game.currentRound = 3;
        game.makeMove(0, 0);
        game.resetAll();

        expect(game.scoreX, 0);
        expect(game.scoreO, 0);
        expect(game.currentRound, 1);
        expect(game.board[0][0], PlayerEnum.none);
        // O jogador inicial é escolhido aleatoriamente após resetAll
        expect(
          game.currentPlayer == PlayerEnum.x ||
              game.currentPlayer == PlayerEnum.o,
          true,
        );
      });
    });

    group('updateScore', () {
      test('deve incrementar scoreX quando X vence', () {
        game.winner = PlayerEnum.x;
        game.updateScore();
        expect(game.scoreX, 1);
        expect(game.scoreO, 0);
      });

      test('deve incrementar scoreO quando O vence', () {
        game.winner = PlayerEnum.o;
        game.updateScore();
        expect(game.scoreX, 0);
        expect(game.scoreO, 1);
      });

      test('não deve incrementar quando não há vencedor', () {
        game.winner = null;
        game.updateScore();
        expect(game.scoreX, 0);
        expect(game.scoreO, 0);
      });

      test('deve incrementar múltiplas vezes', () {
        game.winner = PlayerEnum.x;
        game.updateScore();
        game.updateScore();
        expect(game.scoreX, 2);
      });
    });

    group('nextRound', () {
      test('deve incrementar o round', () {
        // Simula uma vitória para terminar o jogo
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence
        expect(game.currentRound, 1);

        game.nextRound();
        expect(game.currentRound, 2);
      });

      test('deve resetar o tabuleiro', () {
        // Simula uma vitória para terminar o jogo
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence
        expect(game.isGameOver, true);

        game.nextRound();
        expect(game.board[0][0], PlayerEnum.none);
        expect(game.isGameOver, false);
      });

      test('deve fazer o vencedor anterior começar', () {
        // Simula vitória do X
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence
        expect(game.winner, PlayerEnum.x);

        game.nextRound();
        expect(game.currentPlayer, PlayerEnum.x);
        expect(game.currentRound, 2);

        // Simula vitória do O no próximo round
        game.makeMove(1, 0); // X
        game.makeMove(0, 0); // O
        game.makeMove(1, 1); // X
        game.makeMove(0, 1); // O
        game.makeMove(2, 2); // X
        game.makeMove(0, 2); // O vence
        expect(game.winner, PlayerEnum.o);

        game.nextRound();
        expect(game.currentPlayer, PlayerEnum.o);
        expect(game.currentRound, 3);
      });

      test('deve manter X como jogador inicial se não houve vencedor', () {
        // Simula um empate (sem vitória)
        // X: (0,1), (1,0), (1,2), (2,0), (2,2) - 5 movimentos
        // O: (0,0), (0,2), (1,1), (2,1) - 4 movimentos
        game.makeMove(0, 1); // X
        game.makeMove(0, 0); // O
        game.makeMove(1, 0); // X
        game.makeMove(0, 2); // O
        game.makeMove(1, 2); // X
        game.makeMove(1, 1); // O
        game.makeMove(2, 0); // X
        game.makeMove(2, 1); // O
        game.makeMove(2, 2); // X - empate (último movimento)
        expect(game.winner, isNull);
        expect(game.isGameOver, true);

        game.nextRound();
        expect(game.currentPlayer, PlayerEnum.x);
        expect(game.currentRound, 2);
      });
    });

    group('isAllRoundsFinished', () {
      test('deve retornar false quando currentRound < maxRounds', () {
        game.currentRound = 1;
        expect(game.isAllRoundsFinished, false);

        game.currentRound = 4;
        expect(game.isAllRoundsFinished, false);
      });

      test('deve retornar true quando currentRound >= maxRounds', () {
        game.currentRound = 5;
        expect(game.isAllRoundsFinished, true);

        game.currentRound = 6;
        expect(game.isAllRoundsFinished, true);
      });
    });

    group('overallWinner', () {
      test('deve retornar X quando scoreX > scoreO', () {
        game.scoreX = 3;
        game.scoreO = 2;
        expect(game.overallWinner, PlayerEnum.x);
      });

      test('deve retornar O quando scoreO > scoreX', () {
        game.scoreX = 1;
        game.scoreO = 3;
        expect(game.overallWinner, PlayerEnum.o);
      });

      test('deve retornar null quando scores são iguais', () {
        game.scoreX = 2;
        game.scoreO = 2;
        expect(game.overallWinner, isNull);
      });

      test('deve retornar null quando ambos scores são zero', () {
        game.scoreX = 0;
        game.scoreO = 0;
        expect(game.overallWinner, isNull);
      });
    });

    group('makeMove', () {
      test('deve fazer movimento válido', () {
        expect(game.makeMove(0, 0), true);
        expect(game.board[0][0], PlayerEnum.x);
      });

      test('deve alternar jogador após movimento válido', () {
        game.makeMove(0, 0);
        expect(game.currentPlayer, PlayerEnum.o);

        game.makeMove(0, 1);
        expect(game.currentPlayer, PlayerEnum.x);
      });

      test('não deve fazer movimento em casa ocupada', () {
        game.makeMove(0, 0);
        expect(game.makeMove(0, 0), false);
        expect(game.board[0][0], PlayerEnum.x);
      });

      test('não deve fazer movimento quando jogo acabou', () {
        // Simula vitória
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence

        expect(game.isGameOver, true);
        expect(game.makeMove(2, 2), false);
      });

      group('Vitória por linha', () {
        test('deve detectar vitória na primeira linha', () {
          game.makeMove(0, 0); // X
          game.makeMove(1, 0); // O
          game.makeMove(0, 1); // X
          game.makeMove(1, 1); // O
          game.makeMove(0, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });

        test('deve detectar vitória na segunda linha', () {
          game.makeMove(1, 0); // X
          game.makeMove(0, 0); // O
          game.makeMove(1, 1); // X
          game.makeMove(0, 1); // O
          game.makeMove(1, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });

        test('deve detectar vitória na terceira linha', () {
          game.makeMove(2, 0); // X
          game.makeMove(0, 0); // O
          game.makeMove(2, 1); // X
          game.makeMove(0, 1); // O
          game.makeMove(2, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });
      });

      group('Vitória por coluna', () {
        test('deve detectar vitória na primeira coluna', () {
          game.makeMove(0, 0); // X
          game.makeMove(0, 1); // O
          game.makeMove(1, 0); // X
          game.makeMove(0, 2); // O
          game.makeMove(2, 0); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });

        test('deve detectar vitória na segunda coluna', () {
          game.makeMove(0, 1); // X
          game.makeMove(0, 0); // O
          game.makeMove(1, 1); // X
          game.makeMove(0, 2); // O
          game.makeMove(2, 1); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });

        test('deve detectar vitória na terceira coluna', () {
          game.makeMove(0, 2); // X
          game.makeMove(0, 0); // O
          game.makeMove(1, 2); // X
          game.makeMove(0, 1); // O
          game.makeMove(2, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });
      });

      group('Vitória por diagonal', () {
        test('deve detectar vitória na diagonal principal', () {
          game.makeMove(0, 0); // X
          game.makeMove(0, 1); // O
          game.makeMove(1, 1); // X
          game.makeMove(0, 2); // O
          game.makeMove(2, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });

        test('deve detectar vitória na diagonal secundária', () {
          game.makeMove(0, 2); // X
          game.makeMove(0, 0); // O
          game.makeMove(1, 1); // X
          game.makeMove(0, 1); // O
          game.makeMove(2, 0); // X vence

          expect(game.winner, PlayerEnum.x);
          expect(game.isGameOver, true);
        });
      });

      group('Vitória do jogador O', () {
        test('deve detectar vitória do O', () {
          game.makeMove(0, 0); // X
          game.makeMove(1, 0); // O
          game.makeMove(0, 1); // X
          game.makeMove(1, 1); // O
          game.makeMove(2, 2); // X
          game.makeMove(1, 2); // O vence

          expect(game.winner, PlayerEnum.o);
          expect(game.isGameOver, true);
        });
      });

      group('Empate', () {
        test(
          'deve detectar empate quando tabuleiro está cheio sem vencedor',
          () {
            // Sequência que resulta em empate (sem vitória)
            // X: (0,1), (1,0), (1,2), (2,0), (2,2) - 5 movimentos
            // O: (0,0), (0,2), (1,1), (2,1) - 4 movimentos
            game.makeMove(0, 1); // X
            game.makeMove(0, 0); // O
            game.makeMove(1, 0); // X
            game.makeMove(0, 2); // O
            game.makeMove(1, 2); // X
            game.makeMove(1, 1); // O
            game.makeMove(2, 0); // X
            game.makeMove(2, 1); // O
            game.makeMove(2, 2); // X - empate (último movimento)

            expect(game.winner, isNull);
            expect(game.isGameOver, true);
          },
        );

        test(
          'não deve detectar vitória quando tabuleiro não está cheio e não há linha/coluna/diagonal completa',
          () {
            // Faz alguns movimentos sem completar linha, coluna ou diagonal
            game.makeMove(0, 0); // X
            game.makeMove(0, 1); // O
            game.makeMove(1, 1); // X
            game.makeMove(2, 2); // O
            game.makeMove(0, 2); // X

            // Verifica que não há vencedor e o jogo não acabou
            expect(game.winner, isNull);
            expect(game.isGameOver, false);
          },
        );
      });
    });

    group('Cenários de integração', () {
      test(
        'deve completar um jogo completo com vitória e atualizar pontuação',
        () {
          // Jogo 1: X vence
          game.makeMove(0, 0); // X
          game.makeMove(1, 0); // O
          game.makeMove(0, 1); // X
          game.makeMove(1, 1); // O
          game.makeMove(0, 2); // X vence

          expect(game.winner, PlayerEnum.x);
          game.updateScore();
          expect(game.scoreX, 1);
          expect(game.scoreO, 0);

          // Próximo round
          game.nextRound();
          expect(game.currentRound, 2);
          expect(game.currentPlayer, PlayerEnum.x);
          expect(game.isGameOver, false);
          expect(game.winner, isNull);
        },
      );

      test('deve gerenciar múltiplos rounds corretamente', () {
        // Round 1: X vence
        game.makeMove(0, 0); // X
        game.makeMove(1, 0); // O
        game.makeMove(0, 1); // X
        game.makeMove(1, 1); // O
        game.makeMove(0, 2); // X vence
        game.updateScore();

        game.nextRound();
        expect(game.currentRound, 2);
        expect(game.currentPlayer, PlayerEnum.x);

        // Round 2: O vence
        game.makeMove(1, 0); // X
        game.makeMove(0, 0); // O
        game.makeMove(1, 1); // X
        game.makeMove(0, 1); // O
        game.makeMove(2, 2); // X
        game.makeMove(0, 2); // O vence
        game.updateScore();

        expect(game.scoreX, 1);
        expect(game.scoreO, 1);

        game.nextRound();
        expect(game.currentRound, 3);
        expect(game.currentPlayer, PlayerEnum.o);
      });
    });
  });
}
