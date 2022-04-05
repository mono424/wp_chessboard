library wp_chessboard;

import 'dart:math';
import 'dart:ui';

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
    for (Arrow arrow in arrows) {

      double squareWidth = size.width / 8;
      double arrowHeadLen = squareWidth * 0.24;
      PointMode pointMode = PointMode.polygon;
      Offset from = getPosition(arrow.from);
      Offset to = getPosition(arrow.to);
      ParagraphBuilder labelBuilder = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ));

      // Line
      double angle = atan2(to.dy - from.dy, to.dx - from.dx);
      Paint linePaint = Paint()
        ..color = arrow.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(pointMode, [from, to], linePaint);

      // Arrow
      canvas.drawPoints(pointMode, [Offset(to.dx - arrowHeadLen * cos(angle - pi / 6), to.dy - arrowHeadLen * sin(angle - pi / 6)), to], linePaint);
      canvas.drawPoints(pointMode, [Offset(to.dx - arrowHeadLen * cos(angle + pi / 6), to.dy - arrowHeadLen * sin(angle + pi / 6)), to], linePaint);

      // Circle
      // Paint circlePaint1 = Paint()..color = arrow.color;
      // Paint circlePaint2 = Paint()..color = Colors.white;
      // canvas.drawCircle(to, 14, circlePaint1);
      // canvas.drawCircle(to, 10, circlePaint2);

      canvas.drawParagraph(
          labelBuilder.build()
            ..layout(ParagraphConstraints(width: squareWidth)),
          Offset(to.dx - (squareWidth / 2), to.dy - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}