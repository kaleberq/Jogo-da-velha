import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/components/horizontal_divider_component.dart';
import 'package:jogo_da_velha/presentation/components/row_component.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
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
                RowComponent(),
                HorizontalDividerComponent(),
                RowComponent(),
                HorizontalDividerComponent(),
                RowComponent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
