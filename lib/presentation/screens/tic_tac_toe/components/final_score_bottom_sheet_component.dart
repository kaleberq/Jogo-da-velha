import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';

class FinalScoreBottomSheetComponent extends StatelessWidget {
  final String winnerMessage;
  final int scoreX;
  final int scoreO;
  final Function() resetAll;

  const FinalScoreBottomSheetComponent({
    required this.winnerMessage,
    required this.scoreX,
    required this.scoreO,
    required this.resetAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: DSSpacing.lg,
        children: [
          // Título da Bottom Sheet
          Text('Fim de Jogo', style: DSTypographySemiBold.labelXLarge),
          //const DSDivider.horizontal(),

          // Mensagem do Vencedor
          Text(
            winnerMessage,
            style: DSTypographyMedium.labelLarge,
            textAlign: TextAlign.center,
          ),

          // Placar Final
          _buildScoreDetails(context),

          //const DSDivider.horizontal(),

          // Botão de Ação
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.primary,
                foregroundColor: DSColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
              ),
              child: Text(
                'Jogar Novamente',
                style: DSTypographySemiBold.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(BuildContext context) {
    return Column(
      spacing: DSSpacing.sm,
      children: [
        Text('Placar Final', style: DSTypographyRegular.labelMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayerScore(context, player: 'Jogador X', score: scoreX),
            _buildPlayerScore(context, player: 'Jogador O', score: scoreO),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerScore(
    BuildContext context, {
    required String player,
    required int score,
  }) {
    return Column(
      spacing: DSSpacing.md,
      children: [
        Text(player, style: DSTypographyMedium.labelLarge),
        Text(score.toString()),
      ],
    );
  }
}
