import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/screens/components/animated_border_painter.dart';
import 'package:jogo_da_velha/presentation/screens/components/row_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/winning_line_overlay_component.dart';

class GameBoardComponent extends StatelessWidget {
  final TicTacToeGameModel game;
  final Animation<double> winningLineAnimation;
  final Animation<double>? borderAnimation;
  final Function({required int rowIndex, required int columnIndex})? onCellTap;

  const GameBoardComponent({
    super.key,
    required this.game,
    required this.winningLineAnimation,
    this.borderAnimation,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double size = maxWidth * sqrt(1);

        return Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: DSColors.resolveBackgroundInverseColor(context),
                border: Border.all(
                  color: DSColors.resolveGreyColor(context),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Column(
                children: [
                  RowComponent(
                    rowIndex: 0,
                    row: game.board[0],
                    onCellTap:
                        ({required int rowIndex, required int columnIndex}) =>
                            onCellTap?.call(
                              rowIndex: rowIndex,
                              columnIndex: columnIndex,
                            ),
                  ),
                  DsDivider(),
                  RowComponent(
                    rowIndex: 1,
                    row: game.board[1],
                    onCellTap:
                        ({required int rowIndex, required int columnIndex}) =>
                            onCellTap?.call(
                              rowIndex: rowIndex,
                              columnIndex: columnIndex,
                            ),
                  ),
                  DsDivider(),
                  RowComponent(
                    rowIndex: 2,
                    row: game.board[2],
                    onCellTap:
                        ({required int rowIndex, required int columnIndex}) =>
                            onCellTap?.call(
                              rowIndex: rowIndex,
                              columnIndex: columnIndex,
                            ),
                  ),
                ],
              ),
            ),
            if (game.winningLine != null)
              AnimatedBuilder(
                animation: winningLineAnimation,
                builder: (context, child) {
                  return WinningLineOverlayComponent(
                    winningLine: game.winningLine,
                    boardSize: size,
                    animationProgress: winningLineAnimation.value,
                    lineColor: DSColors.resolveBackgroundColor(context),
                  );
                },
              ),
            // Borda animada verde
            if (borderAnimation != null)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: borderAnimation!,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size, size),
                      painter: AnimatedBorderPainter(
                        progress: borderAnimation!.value,
                        borderColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
