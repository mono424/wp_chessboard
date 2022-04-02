library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/square_info.dart';

class DropTargets extends StatelessWidget {
  final double size;
  final void Function(PieceDropEvent)? onPieceDrop;

  const DropTargets({Key? key, required this.size, this.onPieceDrop}) : super(key: key);

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
            child: DragTarget<SquareInfo>(
              onWillAccept: (data) {
                return data != null && data.index != info.index;
              },
              onAccept: (data) {
                if (onPieceDrop != null) {
                  onPieceDrop!(PieceDropEvent(data, info));
                }
              },
              builder: (
                (context, candidateData, rejectedData) => SizedBox(width: squareSize, height: squareSize)
              ),
            ),
          );
        }
      ).toList(),
    );
  }

}