import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/components/horizontal_divider_component.dart';
import 'package:jogo_da_velha/presentation/components/row_component.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  final TicTacToeGame game = TicTacToeGame();

  void _onCellTap(int row, int col) {
    if (game.makeMove(row, col)) {
      setState(() {});
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (game.isGameOver) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleRoundEnd();
      });
    }
  }

  void _handleRoundEnd() {
    // Atualiza pontuação
    game.updateScore();

    // Verifica se chegou ao fim dos 5 rounds
    if (game.isAllRoundsFinished) {
      _showFinalScoreDialog();
    } else {
      _showRoundEndDialog();
    }
  }

  void _showRoundEndDialog() {
    String message;
    if (game.winner != null) {
      message =
          'Jogador ${game.winner == Player.x ? 'X' : 'O'} venceu este round!';
    } else {
      message = 'Empate neste round!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Round ${game.currentRound} - Fim'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Text(
                'Placar: X: ${game.scoreX} | O: ${game.scoreO}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Próximo: Round ${game.currentRound + 1}/${TicTacToeGame.maxRounds}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nextRound();
              },
              child: const Text('Próximo Round'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalScoreDialog() {
    String winnerMessage;
    final Player? overallWinner = game.overallWinner;
    if (overallWinner == Player.x) {
      winnerMessage = 'Jogador X venceu o jogo!';
    } else if (overallWinner == Player.o) {
      winnerMessage = 'Jogador O venceu o jogo!';
    } else {
      winnerMessage = 'Empate! Ninguém venceu.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fim do Jogo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winnerMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Placar Final:',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Jogador X: ${game.scoreX}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Jogador O: ${game.scoreO}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetAll();
              },
              child: const Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  void _nextRound() {
    setState(() {
      game.nextRound();
    });
  }

  void _resetAll() {
    setState(() {
      game.resetAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAll,
            tooltip: 'Reiniciar Tudo',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Informações do jogo
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Text(
                    'Round ${game.currentRound}/${TicTacToeGame.maxRounds}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'X: ${game.scoreX}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'O: ${game.scoreO}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Indicador de jogador atual
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: game.currentPlayer == Player.x
                    ? Colors.blue.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: game.currentPlayer == Player.x
                      ? Colors.blue
                      : Colors.red,
                  width: 2,
                ),
              ),
              child: Text(
                'Vez do jogador: ${game.currentPlayer == Player.x ? 'X' : 'O'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: game.currentPlayer == Player.x
                      ? Colors.blue
                      : Colors.red,
                ),
              ),
            ),
            // Tabuleiro
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade800, width: 3),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RowComponent(
                      rowIndex: 0,
                      row: game.board[0],
                      onCellTap: _onCellTap,
                    ),
                    const HorizontalDividerComponent(),
                    RowComponent(
                      rowIndex: 1,
                      row: game.board[1],
                      onCellTap: _onCellTap,
                    ),
                    const HorizontalDividerComponent(),
                    RowComponent(
                      rowIndex: 2,
                      row: game.board[2],
                      onCellTap: _onCellTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
