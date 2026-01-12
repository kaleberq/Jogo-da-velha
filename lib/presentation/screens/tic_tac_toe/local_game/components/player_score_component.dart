import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';

class PlayerScore extends StatelessWidget {
  final String player;
  final int score;

  const PlayerScore({super.key, required this.player, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: DSSpacing.xs,
      children: [
        Text(player, style: DSTypographyMedium.labelSmall),
        Text(score.toString(), style: DSTypographySemiBold.labelXLarge),
      ],
    );
  }
}
