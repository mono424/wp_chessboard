library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/drop_targets.dart';
import 'package:wp_chessboard/components/hints.dart';
import 'package:wp_chessboard/components/pieces.dart';
import 'package:wp_chessboard/components/squares.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/hint_map.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/square_info.dart';

import 'models/piece_map.dart';

class WPChessboard extends StatefulWidget {
  final double size;
  final Widget Function(SquareInfo) squareBuilder;
  final PieceMap pieceMap;
  final WPChessboardController controller;
  final void Function(SquareInfo file, String piece)? onPieceTap;
  final void Function(PieceDropEvent)? onPieceDrop;


  const WPChessboard({Key? key, required this.size, required this.squareBuilder, required this.pieceMap, required this.controller, this.onPieceTap, this.onPieceDrop}) : super(key: key);

  @override
  State<WPChessboard> createState() => _WPChessboardState();
}

class _WPChessboardState extends State<WPChessboard> {
  String fen = "";
  HintMap hints = HintMap();

  @override
  void initState() {
    fen = widget.controller.fen;
    widget.controller.addListener(() {
      if (fen != widget.controller.fen) {
        onUpdateFen(widget.controller.fen);
      }
      if (hints.id != widget.controller.hints.id) {
        onUpdateHints(widget.controller.hints);
      }
    });
    super.initState();
  }

  void onUpdateFen(String newFen) {
    setState(() {
      fen = newFen;
    });
  }

  void onUpdateHints(HintMap newHints) {
    setState(() {
      hints = newHints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          Squares(
            key: Key("squares_" + widget.size.toString()),
            size: widget.size,
            squareBuilder: widget.squareBuilder,
          ),

          Positioned.fill(
            child: Pieces(
              key: Key("squares_" + widget.size.toString() + "_" + fen),
              size: widget.size,
              pieceMap: widget.pieceMap,
              state: ChessState(fen),
              onPieceTap: widget.onPieceTap
            ),
          ),

          Positioned.fill(
            child: Hints(
              size: widget.size,
              hints: hints,
            ),
          ),

          Positioned.fill(
            child: DropTargets(
              size: widget.size,
              onPieceDrop: widget.onPieceDrop,
            ),
          ),
        ],
      )
    );
  }
}

class WPChessboardController extends ChangeNotifier {
  String fen = "";
  HintMap hints = HintMap();

  WPChessboardController({ this.fen = "" });

  void setFen(String value, { bool resetHints = true }) {
    fen = value;
    if (resetHints) {
      hints = HintMap();
    }
    notifyListeners();
  }

  void setHints(HintMap value) {
    hints = value;
    notifyListeners();
  }
}