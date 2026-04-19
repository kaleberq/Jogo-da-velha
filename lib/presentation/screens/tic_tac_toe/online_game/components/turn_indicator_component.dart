import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/app/theme/app_colors.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class TurnIndicatorComponent extends StatelessWidget {
  final PlayerRole playerRole;
  final bool isMyTurn;
  final PlayerEnum currentPlayer;

  const TurnIndicatorComponent({
    super.key,
    required this.playerRole,
    required this.isMyTurn,
    required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = currentPlayer == PlayerEnum.x
        ? AppColors.playerX
        : AppColors.playerO;
    final String message = isMyTurn
        ? context.l10n.yourTurn
        : context.l10n.waiting;

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: DSTypographySemiBold.labelLarge.copyWith(
            color: DSColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
