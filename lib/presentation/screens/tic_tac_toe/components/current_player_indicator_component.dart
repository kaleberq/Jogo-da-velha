import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';

class CurrentPlayerIndicatorComponent extends StatelessWidget {
  final TicTacToeGameModel game;

  const CurrentPlayerIndicatorComponent({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: game.currentPlayer == PlayerEnum.x
            ? Colors.blue.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: game.currentPlayer == PlayerEnum.x ? Colors.blue : Colors.red,
          width: 2,
        ),
      ),
      child: Text(
        'Vez do jogador: ${game.currentPlayer.value}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: game.currentPlayer == PlayerEnum.x ? Colors.blue : Colors.red,
        ),
      ),
    );
  }
}
