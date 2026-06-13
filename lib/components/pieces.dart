library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/animated_piece_wrap.dart';
import 'package:wp_chessboard/models/board_orientation.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/piece_map.dart';
import 'package:wp_chessboard/models/square_info.dart';

class Pieces extends StatelessWidget {
  final double size;
  final PieceMap pieceMap;
  final ChessState state;
  final BoardOrientation orientation;
  final void Function(SquareInfo square, String piece)? onPieceTap;
  final void Function(SquareInfo square, String piece)? onPieceStartDrag;
  final void Function(SquareInfo square)? onEmptyFieldTap;
  final void Function(PieceDropEvent)? onPieceDrop;
  final bool animated;
  final bool disableDrag;
  final bool ghostOnDrag;
  final bool turnTopPlayerPieces;

  const Pieces({Key? key, required this.size, required this.pieceMap, required this.state, this.onPieceTap, this.onEmptyFieldTap, this.onPieceStartDrag, this.onPieceDrop, required this.animated, required this.orientation, required this.disableDrag, required this.ghostOnDrag, required this.turnTopPlayerPieces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double squareSize = size / 8;

    return Stack(
      children: (List<int>.generate(64, (i) => i + 1)).map(
        (i) {
          SquareInfo info = SquareInfo(i - 1, squareSize);
          StateEntry pieceEntry = state.getEntry(info.rank, info.file);
          
          double left = (info.file - 1) * squareSize;
          double bottom = (info.rank - 1) * squareSize;

          if (pieceEntry.piece == "") {
            return Positioned(
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
            );
          }

          Widget pieceWidget = pieceMap.get(pieceEntry.piece)(squareSize);

          bool isBlackPiece = pieceEntry.piece.toLowerCase() == pieceEntry.piece;
          bool shouldTurnPiece = turnTopPlayerPieces && (
            (orientation == BoardOrientation.black && !isBlackPiece)
            || (orientation == BoardOrientation.white && isBlackPiece)
          );

          return AnimatedPieceWrap(
            key: Key(pieceEntry.getKey()),
            squareSize: squareSize,
            stateEntry: pieceEntry,
            animated: animated,
            child: GestureDetector(
              onTapDown: onPieceTap != null ? (_) => onPieceTap!(info, pieceEntry.piece) : null,
              child: RotatedBox(
                quarterTurns: ((orientation == BoardOrientation.black) ? 2 : 0) + (shouldTurnPiece ? 2 : 0),
                child: disableDrag ? pieceWidget : Draggable<SquareInfo>(
                  onDragStarted: onPieceStartDrag != null ? () => onPieceStartDrag!(info, pieceEntry.piece) : null,
                  // Resolve the drop from the release position rather than relying
                  // on DragTarget hit-testing (which is unreliable on Flutter web).
                  // onDragEnd always fires on pointer-up; we map the dropped
                  // feedback's centre back to a board square and emit the move.
                  onDragEnd: onPieceDrop != null ? (details) {
                    final RenderBox? boardBox = context.findRenderObject() as RenderBox?;
                    if (boardBox == null) return;
                    final Offset local = boardBox.globalToLocal(details.offset);
                    final int toFile = ((local.dx + squareSize / 2) / squareSize).floor();
                    final int toRankFromTop = ((local.dy + squareSize / 2) / squareSize).floor();
                    final int toRank = 7 - toRankFromTop;
                    if (toFile < 0 || toFile > 7 || toRank < 0 || toRank > 7) return;
                    final SquareInfo target = SquareInfo(toRank * 8 + toFile, squareSize);
                    if (target.index == info.index) return;
                    onPieceDrop!(PieceDropEvent(info, target));
                  } : null,
                  childWhenDragging: ghostOnDrag ? Opacity(opacity: 0.2, child: pieceWidget) : const SizedBox(),
                  data: info,
                  feedback: pieceWidget,
                  child: pieceWidget,
                )
              ),
            ),
          );
        }
      ).toList(),
    );
  }

}