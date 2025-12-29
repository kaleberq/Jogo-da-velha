import 'package:jogo_da_velha/domain/models/winning_line_model.dart';
import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/enums/winning_line_enum.dart';

class WinningLinePainterComponent extends CustomPainter {
  final WinningLineModel winningLine;
  final double boardSize;
  final double animationProgress; // 0.0 a 1.0

  WinningLinePainterComponent({
    required this.winningLine,
    required this.boardSize,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cellSize = boardSize / 3;
    final padding = cellSize * 0.15; // 15% de padding em cada lado

    switch (winningLine.type) {
      case WinningLineEnum.horizontal:
        final y = (winningLine.index! + 0.5) * cellSize;
        final startX = padding;
        final endX = boardSize - padding;
        final currentEndX = startX + (endX - startX) * animationProgress;
        canvas.drawLine(Offset(startX, y), Offset(currentEndX, y), paint);
        break;

      case WinningLineEnum.vertical:
        final x = (winningLine.index! + 0.5) * cellSize;
        final startY = padding;
        final endY = boardSize - padding;
        final currentEndY = startY + (endY - startY) * animationProgress;
        canvas.drawLine(Offset(x, startY), Offset(x, currentEndY), paint);
        break;

      case WinningLineEnum.diagonalMain:
        final start = Offset(padding, padding);
        final end = Offset(boardSize - padding, boardSize - padding);
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * animationProgress,
          start.dy + (end.dy - start.dy) * animationProgress,
        );
        canvas.drawLine(start, currentEnd, paint);
        break;

      case WinningLineEnum.diagonalSecondary:
        final start = Offset(boardSize - padding, padding);
        final end = Offset(padding, boardSize - padding);
        final currentEnd = Offset(
          start.dx + (end.dx - start.dx) * animationProgress,
          start.dy + (end.dy - start.dy) * animationProgress,
        );
        canvas.drawLine(start, currentEnd, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(WinningLinePainterComponent oldDelegate) {
    return winningLine != oldDelegate.winningLine ||
        boardSize != oldDelegate.boardSize ||
        animationProgress != oldDelegate.animationProgress;
  }
}
