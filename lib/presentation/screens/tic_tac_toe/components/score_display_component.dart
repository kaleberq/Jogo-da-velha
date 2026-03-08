import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScoreDisplayComponent extends StatelessWidget {
  final int scoreO;
  final int scoreX;
  final PlayerEnum currentPlayer;

  /// No jogo online: jogador que o usuário está usando (X ou O). Placar mostra esse jogador à esquerda.
  final PlayerEnum? localPlayer;

  const ScoreDisplayComponent({
    super.key,

    this.localPlayer,
    required this.scoreO,
    required this.scoreX,
    required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final bool oFirst = localPlayer == PlayerEnum.o;
    final PlayerEnum leftPlayer = oFirst ? PlayerEnum.o : PlayerEnum.x;
    final int leftScore = oFirst ? scoreO : scoreX;
    final PlayerEnum rightPlayer = oFirst ? PlayerEnum.x : PlayerEnum.o;
    final int rightScore = oFirst ? scoreX : scoreO;

    return IntrinsicHeight(
      child: Row(
        spacing: DSSpacing.md,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: leftPlayer.color, width: 5),
                boxShadow: currentPlayer == leftPlayer
                    ? [
                        BoxShadow(
                          color: leftPlayer.color.withValues(alpha: 0.3),
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
                    leftScore,
                    (_) => SvgPicture.asset(
                      leftPlayer.assetPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        leftPlayer.color,
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
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.all(DSSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadius.md),
                border: Border.all(color: rightPlayer.color, width: 5),
                boxShadow: currentPlayer == rightPlayer
                    ? [
                        BoxShadow(
                          color: rightPlayer.color.withValues(alpha: 0.3),
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
                    rightScore,
                    (_) => SvgPicture.asset(
                      rightPlayer.assetPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        rightPlayer.color,
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
