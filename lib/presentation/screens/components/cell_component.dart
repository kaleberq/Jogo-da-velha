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
            child: Center(
              child: Builder(
                builder: (context) {
                  switch (player) {
                    case PlayerEnum.x:
                      return Text(
                        PlayerEnum.x.value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      );
                    case PlayerEnum.o:
                      return Text(
                        PlayerEnum.o.value.toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      );
                    case PlayerEnum.none:
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
