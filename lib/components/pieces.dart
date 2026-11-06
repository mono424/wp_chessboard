library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/animated_piece_wrap.dart';
import 'package:wp_chessboard/models/board_orientation.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/piece_map.dart';
import 'package:wp_chessboard/models/piece_square_args.dart';
import 'package:wp_chessboard/models/square_info.dart';

class Pieces extends StatelessWidget {
  final double size;
  final PieceMap pieceMap;
  final SquarePieceBuilder? pieceBuilder;
  final ChessState state;
  final BoardOrientation orientation;
  final void Function(SquareInfo square, String piece)? onPieceTap;
  final void Function(SquareInfo square, String piece)? onPieceStartDrag;
  final void Function(SquareInfo square)? onEmptyFieldTap;
  final bool animated;
  final bool disableDrag;
  final bool ghostOnDrag;
  final bool turnTopPlayerPieces;

  const Pieces({Key? key, required this.size, required this.pieceMap, this.pieceBuilder, required this.state, this.onPieceTap, this.onEmptyFieldTap, this.onPieceStartDrag, required this.animated, required this.orientation, required this.disableDrag, required this.ghostOnDrag, required this.turnTopPlayerPieces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double squareSize = size / 8;
    final List<Widget> still = [];
    // Pieces that travel on their own, drawn last so they pass over the others.
    final List<Widget> travelling = [];

    for (int i = 0; i < 64; i++) {
      SquareInfo info = SquareInfo(i, squareSize);
      StateEntry pieceEntry = state.getEntry(info.rank, info.file);

      double left = (info.file - 1) * squareSize;
      double bottom = (info.rank - 1) * squareSize;

      if (pieceEntry.piece == "") {
        still.add(Positioned(
          key: Key("piece_" + info.toString() + "_none"),
          bottom: bottom,
          left: left,
          child: GestureDetector(
            onTapDown: onEmptyFieldTap != null ? (_) => onEmptyFieldTap!(info) : null,
            child: Container(
              color: Colors.transparent,
              width: squareSize,
              height: squareSize,
            )
          ),
        ));
        continue;
      }

      bool isBlackPiece = pieceEntry.piece.toLowerCase() == pieceEntry.piece;
      bool shouldTurnPiece = turnTopPlayerPieces && (
        (orientation == BoardOrientation.black && !isBlackPiece)
        || (orientation == BoardOrientation.white && isBlackPiece)
      );
      int quarterTurns = ((orientation == BoardOrientation.black) ? 2 : 0) + (shouldTurnPiece ? 2 : 0);

      Widget pieceWidget = pieceMap.get(pieceEntry.piece)(squareSize);
      Widget feedbackWidget = pieceWidget;
      bool ownsTravel = false;
      final builder = pieceBuilder;
      if (builder != null) {
        final SquarePosition? last = animated ? pieceEntry.lastPosition() : null;
        final SquareInfo? from = last == null ? null : SquareInfo(last.rank * 8 + last.file, squareSize);
        Offset? fromOffset;
        if (from != null) {
          // In the pieces' stack x grows to the right and y downwards, with
          // rank 1 at the bottom. The piece's own frame is turned by its
          // RotatedBox: half a turn flips both axes.
          final Offset onStack = Offset((from.file - info.file) * squareSize, (info.rank - from.rank) * squareSize);
          fromOffset = quarterTurns % 4 == 2 ? -onStack : onStack;
        }
        final built = builder(PieceSquareArgs(
          square: info,
          piece: pieceEntry.piece,
          size: squareSize,
          from: from,
          fromOffset: fromOffset,
          animated: animated,
        ));
        if (built != null) {
          pieceWidget = built.child;
          ownsTravel = built.ownsTravel && from != null;
          if (!disableDrag) {
            feedbackWidget = builder(PieceSquareArgs(
              square: info,
              piece: pieceEntry.piece,
              size: squareSize,
              dragFeedback: true,
            ))?.child ?? pieceMap.get(pieceEntry.piece)(squareSize);
          }
        }
      }

      final Widget wrapped = AnimatedPieceWrap(
        key: Key(pieceEntry.getKey()),
        squareSize: squareSize,
        stateEntry: pieceEntry,
        animated: animated && !ownsTravel,
        child: GestureDetector(
          onTapDown: onPieceTap != null ? (_) => onPieceTap!(info, pieceEntry.piece) : null,
          child: RotatedBox(
            quarterTurns: quarterTurns,
            child: disableDrag ? pieceWidget : Draggable<SquareInfo>(
              onDragStarted: onPieceStartDrag != null ? () => onPieceStartDrag!(info, pieceEntry.piece) : null,
              childWhenDragging: ghostOnDrag ? Opacity(opacity: 0.2, child: feedbackWidget) : const SizedBox(),
              data: info,
              feedback: feedbackWidget,
              child: pieceWidget,
            )
          ),
        ),
      );
      (ownsTravel ? travelling : still).add(wrapped);
    }

    return Stack(children: [...still, ...travelling]);
  }

}
