import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class CellComponent extends StatelessWidget {
  final PlayerEnum player;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double size = constraints.maxWidth;

                return Builder(
                  builder: (context) {
                    switch (player) {
                      case PlayerEnum.x:
                        return Icon(
                          player.value,
                          size: size,
                          color: Colors.blue,
                        );
                      case PlayerEnum.o:
                        return Icon(
                          player.value,
                          size: size,
                          color: Colors.red,
                        );
                      case PlayerEnum.none:
                        return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
