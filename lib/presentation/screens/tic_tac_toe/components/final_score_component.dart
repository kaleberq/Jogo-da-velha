import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/player_score_component.dart';

class FinalScoreComponent extends StatelessWidget {
  final String winnerMessage;
  final int scoreX;
  final int scoreO;
  final VoidCallback resetAll;

  /// No jogo online: jogador que o usuário está usando (X ou O). Placar mostra esse jogador à esquerda.
  final PlayerEnum? localPlayer;

  const FinalScoreComponent({
    required this.winnerMessage,
    required this.scoreX,
    required this.scoreO,
    required this.resetAll,
    this.localPlayer,
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
                  children: localPlayer == PlayerEnum.o
                      ? [
                          PlayerScoreComponent(
                            player: PlayerEnum.o,
                            score: scoreO,
                          ),
                          PlayerScoreComponent(
                            player: PlayerEnum.x,
                            score: scoreX,
                          ),
                        ]
                      : [
                          PlayerScoreComponent(
                            player: PlayerEnum.x,
                            score: scoreX,
                          ),
                          PlayerScoreComponent(
                            player: PlayerEnum.o,
                            score: scoreO,
                          ),
                        ],
                ),
              ],
            ),
          ),
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(context.l10n.backToMenu),
            ),
          ),
        ],
      ),
    );
  }
}
