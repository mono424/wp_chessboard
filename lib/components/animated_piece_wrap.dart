library wp_chessboard;

import 'package:flutter/material.dart';
import 'package:wp_chessboard/models/chess_state.dart';

class AnimatedPieceWrap extends StatefulWidget {
  final Widget child;
  final StateEntry stateEntry;
  final double squareSize;

  const AnimatedPieceWrap({Key? key, required this.child, required this.stateEntry, required this.squareSize}) : super(key: key);

  @override
  State<AnimatedPieceWrap> createState() => _AnimatedPieceWrapState();
}

class _AnimatedPieceWrapState extends State<AnimatedPieceWrap> {
  int rank = 0;
  int file = 0;

  @override
  void initState() {
    SquarePosition? pos = widget.stateEntry.lastPosition();
    if (pos != null) {
      rank = pos.rank;
      file = pos.file;
    } else {
      rank = widget.stateEntry.position.rank;
      file = widget.stateEntry.position.file;
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        rank = widget.stateEntry.position.rank;
        file = widget.stateEntry.position.file;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double left = (file) * widget.squareSize;
    double bottom = (rank) * widget.squareSize;

    return AnimatedPositioned(
      key: Key("animation_" + widget.stateEntry.getKey()),
      curve: Curves.linear,
      duration: const Duration(milliseconds: 200),
      bottom: bottom,
      left: left,
      child: widget.child
    );
  }
}