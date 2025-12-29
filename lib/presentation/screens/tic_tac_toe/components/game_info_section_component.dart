import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';

class GameInfoSectionComponent extends StatelessWidget {
  final TicTacToeGameModel game;

  const GameInfoSectionComponent({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Text(
            'Round ${game.currentRound}/${game.maxRounds}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }
}
