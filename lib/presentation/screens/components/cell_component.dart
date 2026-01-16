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
                final double size = constraints.maxWidth;

                return Builder(
                  builder: (context) {
                    switch (player) {
                      case PlayerEnum.x:
                        return SvgPicture.asset(
                          player.assetPath,
                          width: size,
                          height: size,
                          colorFilter: ColorFilter.mode(
                            PlayerEnum.x.color,
                            BlendMode.srcIn,
                          ),
                        );
                      case PlayerEnum.o:
                        return SvgPicture.asset(
                          player.assetPath,
                          width: size,
                          height: size,
                          colorFilter: ColorFilter.mode(
                            PlayerEnum.o.color,
                            BlendMode.srcIn,
                          ),
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
