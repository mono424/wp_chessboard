library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/shortcut_args.dart';
import 'package:wp_chessboard/models/square_info.dart';

class ShortcutOverlay extends StatelessWidget {
  final double size;
  final int? selFile;
  final int? selRank;
  final ShortcutHighlightBuilder builder;

  const ShortcutOverlay({
    Key? key,
    required this.size,
    required this.selFile,
    required this.selRank,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double squareSize = size / 8;

    if (selFile == null) {
      return const SizedBox();
    }

    return IgnorePointer(
      child: Stack(
        children: List<int>.generate(64, (i) => i + 1).map((i) {
          final info = SquareInfo(i - 1, squareSize);
          final bool selected = info.file == selFile && (selRank == null || info.rank == selRank);

          if (!selected) {
            return const SizedBox.shrink();
          }

          final double left = (info.file - 1) * squareSize;
          final double bottom = (info.rank - 1) * squareSize;

          return Positioned(
            left: left,
            bottom: bottom,
            child: builder(squareSize),
          );
        }).toList(),
      ),
    );
  }
}
