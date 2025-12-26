import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/cell_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/components/vertical_divider_component.dart';
import 'package:jogo_da_velha/presentation/screens/tic_tac_toe/tic_tac_toe_game_view_model.dart';

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
