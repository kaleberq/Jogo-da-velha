import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class RoundEndBottomSheet extends StatelessWidget {
  final String roundEndMessage;
  final PlayerEnum? roundWinner;
  final VoidCallback onNextRound;

  const RoundEndBottomSheet({
    super.key,
    required this.roundEndMessage,
    required this.roundWinner,
    required this.onNextRound,
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
          Expanded(child: Text(roundEndMessage)),
          TextButton(
            onPressed: onNextRound,
            child: Text(context.l10n.nextRound),
          ),
        ],
      ),
    );
  }
}
