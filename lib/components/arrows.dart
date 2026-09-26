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

  /// The stroke width of an arrow that does not ask for one.
  static const double defaultWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final double squareWidth = size.width / 8;
    for (Arrow arrow in arrows) {
      final double width = arrow.width ?? defaultWidth;
      // The head grows a little with the stroke, or a thick arrow ends in a
      // stub. At the default width it is the length it always had.
      final double arrowHeadLen = squareWidth * 0.24 + (width - defaultWidth) * 1.5;
      final Offset from = getPosition(arrow.from);
      final Offset to = getPosition(arrow.to);
      final double angle = atan2(to.dy - from.dy, to.dx - from.dx);

      // Shaft and both barbs as one path.
      final Path path = Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(to.dx, to.dy)
        ..moveTo(to.dx - arrowHeadLen * cos(angle - pi / 6), to.dy - arrowHeadLen * sin(angle - pi / 6))
        ..lineTo(to.dx, to.dy)
        ..lineTo(to.dx - arrowHeadLen * cos(angle + pi / 6), to.dy - arrowHeadLen * sin(angle + pi / 6));
      final Paint linePaint = Paint()
        ..color = arrow.color.withValues(alpha: 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // A translucent arrow is drawn opaque into a layer that is then faded as
      // a whole. Stroking it translucent directly would blend the overlapping
      // shaft and barbs twice and leave a darker tip.
      final double alpha = arrow.color.a;
      if (alpha >= 1) {
        canvas.drawPath(path, linePaint);
        continue;
      }
      canvas.saveLayer(
        path.getBounds().inflate(width),
        Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
      );
      canvas.drawPath(path, linePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}