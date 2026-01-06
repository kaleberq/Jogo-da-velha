import 'package:flutter/material.dart';
import 'package:jogo_da_velha/data/models/tic_tac_toe_game_model.dart';
import 'package:jogo_da_velha/presentation/screens/components/horizontal_divider_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/row_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/winning_line_overlay_component.dart';

class GameBoardComponent extends StatelessWidget {
  final TicTacToeGameModel game;
  final Animation<double> winningLineAnimation;
  final Function({required int rowIndex, required int columnIndex})? onCellTap;

  const GameBoardComponent({
    super.key,
    required this.game,
    required this.winningLineAnimation,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade800, width: 3),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
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
                const HorizontalDividerComponent(),
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
                const HorizontalDividerComponent(),
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
                  boardSize: 300,
                  animationProgress: winningLineAnimation.value,
                );
              },
            ),
        ],
      ),
    );
  }
}
