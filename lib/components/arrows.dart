library wp_chessboard;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/arrow.dart';
import 'package:wp_chessboard/models/square.dart';

class Arrows extends StatelessWidget {
  final double size;
  final List<Arrow> arrows;

  const Arrows({Key? key, required this.size, required this.arrows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ArrowPainter(arrows, size),
        size: Size(size, size),
      )
    );
  }

}

class ArrowPainter extends CustomPainter {
  final double size;
  final List<Arrow> arrows;

  ArrowPainter(this.arrows, this.size);

  Offset getPosition(SquareLocation loc) {
    double squareSize = size / 8;

    return Offset(
      loc.fileIndex * squareSize + (squareSize / 2),
      size - loc.rankIndex * squareSize - (squareSize / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double squareWidth = size.width / 8;
    // Proportional to the square so arrows look right at any board size.
    final double shaftWidth = squareWidth * 0.16;
    final double headLength = squareWidth * 0.36;
    final double headHalfWidth = squareWidth * 0.20;

    for (final Arrow arrow in arrows) {
      final Offset from = getPosition(arrow.from);
      final Offset to = getPosition(arrow.to);
      if (from == to) continue;

      final double angle = atan2(to.dy - from.dy, to.dx - from.dx);
      final Offset dir = Offset(cos(angle), sin(angle));
      // Where the filled head starts; the shaft stops here so it doesn't poke
      // through the tip.
      final Offset headBase = to - dir * headLength;

      // Shaft. Explicit stroke style: drawPoints/fill don't render a visible
      // line on the CanvasKit web renderer, which is why arrows were invisible.
      final Paint shaftPaint = Paint()
        ..color = arrow.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = shaftWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, headBase, shaftPaint);

      // Filled triangular head at the destination square.
      final Offset perp = Offset(-dir.dy, dir.dx) * headHalfWidth;
      final Path head = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(headBase.dx + perp.dx, headBase.dy + perp.dy)
        ..lineTo(headBase.dx - perp.dx, headBase.dy - perp.dy)
        ..close();
      final Paint headPaint = Paint()
        ..color = arrow.color
        ..style = PaintingStyle.fill;
      canvas.drawPath(head, headPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
