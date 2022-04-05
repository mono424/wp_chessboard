import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/square.dart';

class Arrow {
  final SquareLocation from;
  final SquareLocation to;
  final Color color;

  Arrow({required this.from, required this.to, this.color = Colors.green});
}