import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/player_enum.dart';

class CurrentPlayerIndicatorComponent extends StatelessWidget {
  final PlayerEnum currentPlayer;

  const CurrentPlayerIndicatorComponent({
    super.key,
    required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Vez do jogador: ${currentPlayer.value}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: currentPlayer == PlayerEnum.x ? Colors.blue : Colors.red,
      ),
    );
  }
}
