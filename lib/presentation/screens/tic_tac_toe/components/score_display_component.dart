import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScoreDisplayComponent extends StatelessWidget {
  final TicTacToeGameModel game;

  const ScoreDisplayComponent({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: DSSpacing.md,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: DSColors.primary),
            ),
            child: Center(
              child: Row(
                children: List.generate(
                  game.scoreX,
                  (_) => SvgPicture.asset(
                    PlayerEnum.x.assetPath,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      DSColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(DSSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DSRadius.sm),
              border: Border.all(color: DSColors.primary),
            ),
            child: Center(
              child: Row(
                children: List.generate(
                  game.scoreO,
                  (_) => SvgPicture.asset(
                    PlayerEnum.o.assetPath,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      DSColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
