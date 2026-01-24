import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';
import 'package:jogo_da_velha/presentation/screens/components/cell_component.dart';

class RowComponent extends StatelessWidget {
  final int rowIndex;
  final List<PlayerEnum> row;
  final Function({required int rowIndex, required int columnIndex})? onCellTap;

  const RowComponent({
    super.key,
    required this.rowIndex,
    required this.row,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          CellComponent(
            player: row[0],
            onTap: () => onCellTap?.call(rowIndex: rowIndex, columnIndex: 0),
          ),
          DsDivider(dividerType: DsDividerType.vertical),
          CellComponent(
            player: row[1],
            onTap: () => onCellTap?.call(rowIndex: rowIndex, columnIndex: 1),
          ),
          DsDivider(dividerType: DsDividerType.vertical),
          CellComponent(
            player: row[2],
            onTap: () => onCellTap?.call(rowIndex: rowIndex, columnIndex: 2),
          ),
        ],
      ),
    );
  }
}
