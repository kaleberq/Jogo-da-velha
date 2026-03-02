import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
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
    return AppBar(
      title: isMyTurn
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.yourTurn,
                style: DSTypographySemiBold.labelLarge,
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.waiting,
                style: const TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
