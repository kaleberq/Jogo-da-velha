import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/domain/enums/player_role_enum.dart';
import 'package:jogo_da_velha/extensions/app_location_extension.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final PlayerRole playerRole;
  final bool isMyTurn;
  final VoidCallback? onResetPressed;
  final int? currentMaxRounds;
  final Function(int)? onMaxRoundsChanged;

  const AppBarComponent({
    super.key,

    this.playerRole = PlayerRole.guest,
    required this.isMyTurn,
    this.onResetPressed,
    this.currentMaxRounds,
    this.onMaxRoundsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final PlayerEnum myPlayer = playerRole.isHost ? PlayerEnum.x : PlayerEnum.o;
    final PlayerEnum opponentPlayer = playerRole.isHost
        ? PlayerEnum.o
        : PlayerEnum.x;
    final Color badgeColor = isMyTurn ? myPlayer.color : opponentPlayer.color;

    return AppBar(
      centerTitle: true,
      title: isMyTurn
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.yourTurn,
                textAlign: TextAlign.center,
                style: DSTypographySemiBold.labelLarge.copyWith(
                  color: DSColors.onPrimary,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.waiting,
                textAlign: TextAlign.center,
                style: DSTypographySemiBold.labelLarge.copyWith(
                  color: DSColors.onPrimary,
                ),
              ),
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
