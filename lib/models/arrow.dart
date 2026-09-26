import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/square.dart';

class Arrow {
  final SquareLocation from;
  final SquareLocation to;

  /// The arrow's colour. Its alpha is the arrow's opacity: the arrow is drawn
  /// as one path, so a translucent arrow has an even tint, tip included.
  final Color color;

  /// Stroke width in logical pixels. Null draws the default 4.
  final double? width;

  Arrow({required this.from, required this.to, this.color = Colors.green, this.width});
}
