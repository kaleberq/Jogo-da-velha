import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerScoreComponent extends StatelessWidget {
  final PlayerEnum player;
  final int score;

  const PlayerScoreComponent({
    super.key,
    required this.player,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: DSSpacing.xs,
      children: [
        SvgPicture.asset(
          player.assetPath,
          colorFilter: ColorFilter.mode(player.color, BlendMode.srcIn),
          width: 40,
          height: 40,
        ),
        Text(score.toString(), style: DSTypographySemiBold.labelXLarge),
      ],
    );
  }
}
