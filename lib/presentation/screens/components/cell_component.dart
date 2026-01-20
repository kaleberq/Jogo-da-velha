import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                final size = constraints.maxWidth;
                final padding = size * 0.05;

                if (player == PlayerEnum.none) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: SvgPicture.asset(
                    player.assetPath,
                    width: size,
                    height: size,
                    colorFilter: ColorFilter.mode(
                      player.color,
                      BlendMode.srcIn,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
