library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/drop_indicator_args.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/square_info.dart';

class DropTargets extends StatefulWidget {
  final double size;
  final DropIndicatorArgs? dropIndicator;
  final void Function(PieceDropEvent)? onPieceDrop;


  const DropTargets({Key? key, required this.size, this.onPieceDrop, this.dropIndicator}) : super(key: key);

  @override
  State<DropTargets> createState() => _DropTargetsState();
}

class _DropTargetsState extends State<DropTargets> {
  SquareInfo? dropHover;

  void onMove(SquareInfo square, SquareInfo data) {
    if (data.index == square.index) {
      if (dropHover == null) return;
      setState(() {
        dropHover = null;
      });
      return;
    }

    if (dropHover == null || dropHover!.index != square.index) {
      setState(() {
        dropHover = square;
      });
    }
  }

  void onLeave(SquareInfo square) {
    if (dropHover != null && dropHover!.index == square.index) {
      setState(() {
        dropHover = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double squareSize = widget.size / 8;

    return Stack(
      children: [

        Builder(
          builder: (context) {
            if (widget.dropIndicator == null || dropHover == null) return const SizedBox();

            double left = (dropHover!.file - 1) * squareSize + squareSize / 2 - (widget.dropIndicator!.size / 2);
            double bottom = (dropHover!.rank - 1) * squareSize + squareSize / 2 - (widget.dropIndicator!.size / 2);

            return Positioned(
              bottom: bottom,
              left: left,
              child: IgnorePointer(
                child: Container(
                  width: widget.dropIndicator!.size,
                  height: widget.dropIndicator!.size,
                  decoration: BoxDecoration(
                    borderRadius: widget.dropIndicator!.radius,
                    color: widget.dropIndicator!.color,
                  ),
                ),
              )
            );
          },
        ),

        ...(List<int>.generate(64, (i) => i + 1)).map(
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
                  onLeave(info);
                  if (widget.onPieceDrop != null) {
                    widget.onPieceDrop!(PieceDropEvent(data, info));
                  }
                },
                onMove: (data) => onMove(info, data.data),
                onLeave: (data) => onLeave(info),
                builder: (
                  (context, candidateData, rejectedData) => SizedBox(width: squareSize, height: squareSize)
                ),
              ),
            );
          }
        ).toList(),

      ]
    );
  }
}