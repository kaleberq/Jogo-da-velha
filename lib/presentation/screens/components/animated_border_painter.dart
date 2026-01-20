import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_design_system/flutter_design_system.dart';

/// CustomPainter que desenha uma borda animada verde percorrendo o perímetro
class AnimatedBorderPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Color borderColor;

  AnimatedBorderPainter({
    required this.progress,
    this.borderColor = Colors.green,
  });

  final double borderWidth = 3.0;
  final double borderRadius = DSRadius.sm;
  final double containerBorderWidth = 3.0; // Largura da borda do Container

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ajusta o retângulo para desenhar exatamente sobre a borda do Container
    // A borda do Container é desenhada na borda externa, então precisamos
    // desenhar no centro da borda, que fica deslocado pela metade da largura
    final halfBorder = containerBorderWidth / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        halfBorder,
        halfBorder,
        size.width - containerBorderWidth,
        size.height - containerBorderWidth,
      ),
      Radius.circular(borderRadius),
    );

    // Calcula o perímetro total da borda arredondada
    // Perímetro = 2*(width + height) - 8*radius + 2*π*radius
    final straightSides = 2 * (size.width + size.height) - 8 * borderRadius;
    final curvedSides = 2 * math.pi * borderRadius;
    final totalPerimeter = straightSides + curvedSides;

    // Distância percorrida baseada no progresso
    final distance = totalPerimeter * progress.clamp(0.0, 1.0);

    // Desenha a borda progressiva percorrendo o perímetro
    _drawAnimatedBorder(canvas, rect, distance, paint);
  }

  void _drawAnimatedBorder(
    Canvas canvas,
    RRect rect,
    double distance,
    Paint paint,
  ) {
    final path = Path();
    double currentDistance = 0.0;
    final topSideLength = rect.width - 2 * borderRadius;
    final topSideHalf = topSideLength / 2;

    // Começa no meio do lado superior - primeira metade (meio para direita)
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        topSideHalf,
      );
      if (segmentLength > 0) {
        final centerX = rect.left + rect.width / 2;
        path.moveTo(centerX, rect.top);
        path.lineTo(centerX + segmentLength, rect.top);
      }
    }
    currentDistance += topSideHalf;

    // Canto superior direito (arco de 90 graus)
    final topRightArcLength = math.pi * borderRadius / 2;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        topRightArcLength,
      );
      if (segmentLength > 0) {
        final startAngle = -math.pi / 2;
        final sweepAngle = segmentLength / borderRadius;
        path.addArc(
          Rect.fromLTWH(
            rect.right - borderRadius * 2,
            rect.top,
            borderRadius * 2,
            borderRadius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      }
    }
    currentDistance += topRightArcLength;

    // Lado direito (de cima para baixo)
    final rightSideLength = rect.height - 2 * borderRadius;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        rightSideLength,
      );
      if (segmentLength > 0) {
        path.moveTo(rect.right, rect.top + borderRadius);
        path.lineTo(rect.right, rect.top + borderRadius + segmentLength);
      }
    }
    currentDistance += rightSideLength;

    // Canto inferior direito (arco de 90 graus)
    final bottomRightArcLength = math.pi * borderRadius / 2;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        bottomRightArcLength,
      );
      if (segmentLength > 0) {
        final startAngle = 0.0;
        final sweepAngle = segmentLength / borderRadius;
        path.addArc(
          Rect.fromLTWH(
            rect.right - borderRadius * 2,
            rect.bottom - borderRadius * 2,
            borderRadius * 2,
            borderRadius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      }
    }
    currentDistance += bottomRightArcLength;

    // Lado inferior (da direita para esquerda)
    final bottomSideLength = rect.width - 2 * borderRadius;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        bottomSideLength,
      );
      if (segmentLength > 0) {
        path.moveTo(rect.right - borderRadius, rect.bottom);
        path.lineTo(rect.right - borderRadius - segmentLength, rect.bottom);
      }
    }
    currentDistance += bottomSideLength;

    // Canto inferior esquerdo (arco de 90 graus)
    final bottomLeftArcLength = math.pi * borderRadius / 2;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        bottomLeftArcLength,
      );
      if (segmentLength > 0) {
        final startAngle = math.pi / 2;
        final sweepAngle = segmentLength / borderRadius;
        path.addArc(
          Rect.fromLTWH(
            rect.left,
            rect.bottom - borderRadius * 2,
            borderRadius * 2,
            borderRadius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      }
    }
    currentDistance += bottomLeftArcLength;

    // Lado esquerdo (de baixo para cima)
    final leftSideLength = rect.height - 2 * borderRadius;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        leftSideLength,
      );
      if (segmentLength > 0) {
        path.moveTo(rect.left, rect.bottom - borderRadius);
        path.lineTo(rect.left, rect.bottom - borderRadius - segmentLength);
      }
    }
    currentDistance += leftSideLength;

    // Canto superior esquerdo (arco de 90 graus)
    final topLeftArcLength = math.pi * borderRadius / 2;
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        topLeftArcLength,
      );
      if (segmentLength > 0) {
        final startAngle = math.pi;
        final sweepAngle = segmentLength / borderRadius;
        path.addArc(
          Rect.fromLTWH(
            rect.left,
            rect.top,
            borderRadius * 2,
            borderRadius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      }
    }
    currentDistance += topLeftArcLength;

    // Segunda metade do lado superior (esquerda para meio) - completa o círculo
    if (distance > currentDistance) {
      final segmentLength = (distance - currentDistance).clamp(
        0.0,
        topSideHalf,
      );
      if (segmentLength > 0) {
        path.moveTo(rect.left + borderRadius, rect.top);
        path.lineTo(rect.left + borderRadius + segmentLength, rect.top);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AnimatedBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
