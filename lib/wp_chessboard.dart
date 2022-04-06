library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/arrows.dart';
import 'package:wp_chessboard/components/drop_targets.dart';
import 'package:wp_chessboard/components/hints.dart';
import 'package:wp_chessboard/components/pieces.dart';
import 'package:wp_chessboard/components/squares.dart';
import 'package:wp_chessboard/models/arrow.dart';
import 'package:wp_chessboard/models/arrow_list.dart';
import 'package:wp_chessboard/models/board_orientation.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/hint_map.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/square_info.dart';

import 'models/piece_map.dart';

class WPChessboard extends StatefulWidget {
  final double size;
  final Widget Function(SquareInfo) squareBuilder;
  final PieceMap pieceMap;
  final BoardOrientation orientation;
  final WPChessboardController controller;
  final void Function(SquareInfo square, String piece)? onPieceTap;
  final void Function(SquareInfo square, String piece)? onPieceStartDrag;
  final void Function(SquareInfo square)? onEmptyFieldTap;
  final void Function(PieceDropEvent)? onPieceDrop;
  final bool ghostOnDrag;


  const WPChessboard({Key? key, required this.size, required this.squareBuilder, required this.pieceMap, required this.controller, this.onPieceTap, this.onPieceDrop, this.onEmptyFieldTap, this.onPieceStartDrag, this.orientation = BoardOrientation.white, this.ghostOnDrag = false}) : super(key: key);

  @override
  State<WPChessboard> createState() => _WPChessboardState();
}

class _WPChessboardState extends State<WPChessboard> {
  ChessState state = ChessState("");
  HintMap hints = HintMap();
  ArrowList arrows = ArrowList([]); 

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
      if (arrows.id != widget.controller.arrows.id) {
        onUpdateArrows(widget.controller.arrows);
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

  void onUpdateArrows(ArrowList newArrows) {
    setState(() {
      arrows = newArrows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: widget.size,
      height: widget.size,
      child: RotatedBox(
        quarterTurns: (widget.orientation == BoardOrientation.black) ? 2 : 0,
        child: Stack(
          children: [
            Squares(
              key: Key("squares_" + widget.size.toString() + "_" + state.fen),
              size: widget.size,
              squareBuilder: widget.squareBuilder,
            ),

            Positioned.fill(
              child: Pieces(
                key: Key("pieces_" + widget.size.toString() + "_" + state.fen),
                size: widget.size,
                orientation: widget.orientation,
                pieceMap: widget.pieceMap,
                state: state,
                onPieceTap: widget.onPieceTap,
                onPieceStartDrag: widget.onPieceStartDrag,
                disableDrag: widget.onPieceDrop == null,
                ghostOnDrag: widget.ghostOnDrag,
                onEmptyFieldTap: widget.onEmptyFieldTap,
                animated: widget.controller.shouldAnimate
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
              child: Arrows(
                size: widget.size,
                arrows: arrows.value,
              ),
            ),

            Positioned.fill(
              child: DropTargets(
                size: widget.size,
                onPieceDrop: widget.onPieceDrop,
              ),
            ),
          ],
        ),
      )
    );
  }
}

class WPChessboardController extends ChangeNotifier {
  ChessState state = ChessState("");
  HintMap hints = HintMap();
  ArrowList arrows = ArrowList([]);
  bool shouldAnimate = true;

  WPChessboardController();

  void setFen(String value, { bool resetHints = true, bool newGame = false, bool animation = true }) {
    shouldAnimate = animation;

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

  void setArrows(List<Arrow> value) {
    arrows = ArrowList(value);
    notifyListeners();
  }
}