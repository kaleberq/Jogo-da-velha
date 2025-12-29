import 'package:flutter/material.dart';
import 'package:jogo_da_velha/presentation/screens/components/winning_line_painter_component.dart';
import 'package:jogo_da_velha/domain/models/winning_line_model.dart';

class WinningLineOverlayComponent extends StatelessWidget {
  final WinningLineModel? winningLine;
  final double boardSize;
  final double animationProgress;

  const WinningLineOverlayComponent({
    super.key,
    required this.winningLine,
    required this.boardSize,
    this.animationProgress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (winningLine == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: WinningLinePainterComponent(
          winningLine: winningLine!,
          boardSize: boardSize,
          animationProgress: animationProgress,
        ),
      ),
    );
  }
}
