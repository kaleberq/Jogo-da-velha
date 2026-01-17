import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/app/theme/app_colors.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScoreDisplayComponent extends StatelessWidget {
  final TicTacToeGameModel game;

  const ScoreDisplayComponent({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        spacing: DSSpacing.md,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              constraints: BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: AppColors.playerX, width: 5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  children: List.generate(
                    game.scoreX,
                    (_) => SvgPicture.asset(
                      PlayerEnum.x.assetPath,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.playerX,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SvgPicture.asset(PlayerEnum.x.assetPath, width: 20),
          Expanded(
            flex: 1,
            child: Container(
              constraints: BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: AppColors.playerO, width: 5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  children: List.generate(
                    game.scoreO,
                    (_) => SvgPicture.asset(
                      PlayerEnum.o.assetPath,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.playerO,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
