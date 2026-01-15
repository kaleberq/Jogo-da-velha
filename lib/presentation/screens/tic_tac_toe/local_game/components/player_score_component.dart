import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class PlayerScore extends StatelessWidget {
  final PlayerEnum player;
  final int score;

  const PlayerScore({super.key, required this.player, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: DSSpacing.xs,
      children: [
        Icon(player.value, size: 20),
        Text(score.toString(), style: DSTypographySemiBold.labelXLarge),
      ],
    );
  }
}
