import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/components/cell_component.dart';
import 'package:jogo_da_velha/presentation/screens/components/vertical_divider_component.dart';
import 'package:jogo_da_velha/presentation/models/tic_tac_toe_game.dart';

class RowComponent extends StatelessWidget {
  final int rowIndex;
  final List<Player> row;
  final Function(int, int) onCellTap;

  const RowComponent({
    super.key,
    required this.rowIndex,
    required this.row,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          CellComponent(player: row[0], onTap: () => onCellTap(rowIndex, 0)),
          const VerticalDividerComponent(),
          CellComponent(player: row[1], onTap: () => onCellTap(rowIndex, 1)),
          const VerticalDividerComponent(),
          CellComponent(player: row[2], onTap: () => onCellTap(rowIndex, 2)),
        ],
      ),
    );
  }
}
