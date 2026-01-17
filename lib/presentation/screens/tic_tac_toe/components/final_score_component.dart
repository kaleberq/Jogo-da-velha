import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/local_game/components/player_score_component.dart';

class FinalScoreComponent extends StatelessWidget {
  final String winnerMessage;
  final int scoreX;
  final int scoreO;
  final VoidCallback resetAll;

  const FinalScoreComponent({
    required this.winnerMessage,
    required this.scoreX,
    required this.scoreO,
    required this.resetAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.gameEndTitle,
            style: DSTypographySemiBold.labelXLarge,
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            winnerMessage,
            style: DSTypographyMedium.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Column(
              spacing: DSSpacing.md,
              children: [
                Text(
                  context.l10n.finalScore,
                  style: DSTypographyMedium.labelMedium,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PlayerScore(player: PlayerEnum.x, score: scoreX),
                    PlayerScore(player: PlayerEnum.o, score: scoreO),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetAll();
              },
              child: Text(context.l10n.playAgain),
            ),
          ),
        ],
      ),
    );
  }
}
