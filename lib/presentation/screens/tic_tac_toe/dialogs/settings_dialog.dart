import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/data/network/network_service.dart';

class SettingsDialog {
  static void show(
    BuildContext context, {
    required int currentMaxRounds,
    required bool isOnlineMode,
    required bool isHost,
    required NetworkService? networkService,
    required AnimationController winningLineAnimationController,
    required Function(int maxRounds, TicTacToeGameModel newGame) onSave,
  }) {
    int tempMaxRounds = currentMaxRounds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurações'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Número de Rounds:'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: tempMaxRounds > 1
                            ? () {
                                setDialogState(() {
                                  tempMaxRounds--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$tempMaxRounds',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: tempMaxRounds < 20
                            ? () {
                                setDialogState(() {
                                  tempMaxRounds++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha entre 1 e 20 rounds',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    winningLineAnimationController.reset();
                    final newGame = TicTacToeGameModel(
                      maxRounds: tempMaxRounds,
                    );
                    if (isOnlineMode) {
                      networkService?.sendConfig(tempMaxRounds);
                      if (isHost) {
                        newGame.currentPlayer = PlayerEnum.x;
                      } else {
                        newGame.currentPlayer = PlayerEnum.o;
                      }
                    }
                    Navigator.of(context).pop();
                    onSave(tempMaxRounds, newGame);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
