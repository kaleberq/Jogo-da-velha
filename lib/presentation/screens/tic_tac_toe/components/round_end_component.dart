import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class RoundEnd extends StatelessWidget {
  final String roundEndMessage;
  final PlayerEnum? roundWinner;
  final VoidCallback onNextRound;
  final PlayerRole playerRole;

  const RoundEnd({
    required this.roundEndMessage,
    required this.roundWinner,
    required this.onNextRound,
    this.playerRole = PlayerRole.host,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(roundEndMessage, style: DSTypographyMedium.labelLarge),
          ),
          if (playerRole.isHost)
            ElevatedButton(
              onPressed: onNextRound,
              child: Text(context.l10n.nextRound),
            ),
        ],
      ),
    );
  }
}
