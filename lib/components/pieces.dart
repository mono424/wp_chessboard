library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/piece_map.dart';
import 'package:wp_chessboard/models/square_info.dart';

class Pieces extends StatelessWidget {
  final double size;
  final PieceMap pieceMap;
  final ChessState state;
  final void Function(SquareInfo file, String piece)? onPieceTap;

  const Pieces({Key? key, required this.size, required this.pieceMap, required this.state, this.onPieceTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double squareSize = size / 8;

    return Stack(
      children: (List<int>.generate(64, (i) => i + 1)).map(
        (i) {
          SquareInfo info = SquareInfo(i - 1, squareSize);
          String piece = state.getPiece(info.rank, info.file);
          
          double left = (info.file - 1) * squareSize;
          double bottom = (info.rank - 1) * squareSize;

          if (piece == "") return const SizedBox();

          Widget pieceWidget = pieceMap.get(piece)(squareSize);

          return Positioned(
            bottom: bottom,
            left: left,
            child: GestureDetector(
              onTapDown: onPieceTap != null ? (_) => onPieceTap!(info, piece) : null,
              child: Draggable<SquareInfo>(
                data: info,
                feedback: pieceWidget,
                child: pieceWidget,
              )
            ),
          );
        }
      ).toList(),
    );
  }

}