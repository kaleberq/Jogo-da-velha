import 'package:flutter/material.dart';
import 'package:jogo_da_velha/domain/models/winning_line.dart';

class WinningLineOverlay extends StatelessWidget {
  final WinningLine? winningLine;
  final double boardSize;

  const WinningLineOverlay({
    super.key,
    required this.winningLine,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    if (winningLine == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: CustomPaint(
        painter: WinningLinePainter(
          winningLine: winningLine!,
          boardSize: boardSize,
        ),
      ),
    );
  }
}

class WinningLinePainter extends CustomPainter {
  final WinningLine winningLine;
  final double boardSize;

  WinningLinePainter({required this.winningLine, required this.boardSize});

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
      case WinningLineType.horizontal:
        final y = (winningLine.index! + 0.5) * cellSize;
        canvas.drawLine(
          Offset(padding, y),
          Offset(boardSize - padding, y),
          paint,
        );
        break;

      case WinningLineType.vertical:
        final x = (winningLine.index! + 0.5) * cellSize;
        canvas.drawLine(
          Offset(x, padding),
          Offset(x, boardSize - padding),
          paint,
        );
        break;

      case WinningLineType.diagonalMain:
        canvas.drawLine(
          Offset(padding, padding),
          Offset(boardSize - padding, boardSize - padding),
          paint,
        );
        break;

      case WinningLineType.diagonalSecondary:
        canvas.drawLine(
          Offset(boardSize - padding, padding),
          Offset(padding, boardSize - padding),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) {
    return winningLine != oldDelegate.winningLine ||
        boardSize != oldDelegate.boardSize;
  }
}
