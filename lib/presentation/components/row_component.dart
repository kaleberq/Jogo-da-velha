import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/components/cell_component.dart';
import 'package:jogo_da_velha/presentation/components/vertical_divider_component.dart';

class RowComponent extends StatelessWidget {
  const RowComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          CellComponent(),
          VerticalDividerComponent(),
          CellComponent(),
          VerticalDividerComponent(),
          CellComponent(),
        ],
      ),
    );
    ;
  }
}
