import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game.dart';

class CellComponent extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;

  const CellComponent({super.key, required this.player, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Center(
              child: Builder(
                builder: (context) {
                  switch (player) {
                    case Player.x:
                      return const Text(
                        'X',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      );
                    case Player.o:
                      return const Text(
                        'O',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      );
                    case Player.none:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
