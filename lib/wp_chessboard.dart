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
  final void Function(SquareInfo square, String piece)? onPieceTap;
  final void Function(SquareInfo square, String piece)? onPieceStartDrag;
  final void Function(SquareInfo square)? onEmptyFieldTap;
  final void Function(PieceDropEvent)? onPieceDrop;


  const WPChessboard({Key? key, required this.size, required this.squareBuilder, required this.pieceMap, required this.controller, this.onPieceTap, this.onPieceDrop, this.onEmptyFieldTap, this.onPieceStartDrag}) : super(key: key);

  @override
  State<WPChessboard> createState() => _WPChessboardState();
}

class _WPChessboardState extends State<WPChessboard> {
  ChessState state = ChessState("");
  HintMap hints = HintMap();

  @override
  void initState() {
    state = widget.controller.state;
    widget.controller.addListener(() {
      if (state.fen != widget.controller.state.fen) {
        onUpdateState(widget.controller.state);
      }
      if (hints.id != widget.controller.hints.id) {
        onUpdateHints(widget.controller.hints);
      }
    });
    super.initState();
  }

  void onUpdateState(ChessState newState) {
    setState(() {
      state = newState;
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
              key: Key("squares_" + widget.size.toString() + "_" + state.fen),
              size: widget.size,
              pieceMap: widget.pieceMap,
              state: state,
              onPieceTap: widget.onPieceTap,
              onPieceStartDrag: widget.onPieceStartDrag,
              onEmptyFieldTap: widget.onEmptyFieldTap
            ),
          ),

          Positioned.fill(
            child: Hints(
              key: Key(hints.id.toString()),
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
  ChessState state = ChessState("");
  HintMap hints = HintMap();

  WPChessboardController();

  void setFen(String value, { bool resetHints = true, bool newGame = false }) {
    if (newGame) {
      state = ChessState(value, last: null);
    } else {
      state = ChessState(value, last: state);
    }

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