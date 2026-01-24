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
                border: Border.all(color: PlayerEnum.x.color, width: 5),
                boxShadow: game.currentPlayer == PlayerEnum.x
                    ? [
                        BoxShadow(
                          color: PlayerEnum.x.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
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
                      colorFilter: ColorFilter.mode(
                        PlayerEnum.x.color,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SvgPicture.asset(
            PlayerEnum.x.assetPath,
            width: 20,
            colorFilter: ColorFilter.mode(
              DSColors.resolveBackgroundColor(context),
              BlendMode.srcIn,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              constraints: BoxConstraints(minHeight: 50),
              padding: EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: PlayerEnum.o.color, width: 5),
                boxShadow: game.currentPlayer == PlayerEnum.o
                    ? [
                        BoxShadow(
                          color: PlayerEnum.o.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
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
                      colorFilter: ColorFilter.mode(
                        PlayerEnum.o.color,
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
