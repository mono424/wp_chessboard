library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/hint_map.dart';
import 'package:wp_chessboard/models/square_info.dart';

class Hints extends StatelessWidget {
  final double size;
  final HintMap hints;

  const Hints({Key? key, required this.size, required this.hints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double squareSize = size / 8;

    return Stack(
      children: (List<int>.generate(64, (i) => i + 1)).map(
        (i) {
          SquareInfo info = SquareInfo(i - 1, squareSize);

          double left = (info.file - 1) * squareSize;
          double bottom = (info.rank - 1) * squareSize;

          HintBuilder? hint = hints.getHint(info.rank, info.file);

          return Positioned(
            bottom: bottom,
            left: left,
            child: hint != null ? hint(squareSize) : const SizedBox(),
          );
        }
      ).toList(),
    );
  }

}