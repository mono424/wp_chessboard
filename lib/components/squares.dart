library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/square_info.dart';

class Squares extends StatelessWidget {
  final double size;
  final Widget Function(SquareInfo) squareBuilder;

  const Squares({Key? key, required this.size, required this.squareBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double squareSize = size / 8;

    return Stack(
      children: (List<int>.generate(64, (i) => i + 1)).map(
        (i) {
          SquareInfo info = SquareInfo(i - 1, squareSize);

          double left = (info.file - 1) * squareSize;
          double bottom = (info.rank - 1) * squareSize;

          return Positioned(
            bottom: bottom,
            left: left,
            child: squareBuilder(info),
          );
        }
      ).toList(),
    );
  }

}