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
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    String message;
    if (game.winner != null) {
      message = 'Jogador ${game.winner == Player.x ? 'X' : 'O'} venceu!';
    } else {
      message = 'Empate!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fim de Jogo'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Reiniciar Jogo',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
