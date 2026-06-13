library wp_chessboard;

export 'package:wp_chessboard/models/piece_map.dart';
export 'package:wp_chessboard/models/arrow_list.dart';
export 'package:wp_chessboard/models/arrow.dart';
export 'package:wp_chessboard/models/square_info.dart';
export 'package:wp_chessboard/models/piece_drop_event.dart';
export 'package:wp_chessboard/models/board_orientation.dart';
export 'package:wp_chessboard/models/hint_map.dart';
export 'package:wp_chessboard/models/hint_map.dart';
export 'package:wp_chessboard/models/drop_indicator_args.dart';
export 'package:wp_chessboard/models/shortcut_args.dart';
export 'package:wp_chessboard/models/square.dart';
export 'package:wp_chessboard/components/hints/move_hint.dart';
export 'package:wp_chessboard/components/shortcuts/shortcut_highlight.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wp_chessboard/components/arrows.dart';
import 'package:wp_chessboard/components/drop_targets.dart';
import 'package:wp_chessboard/components/hints.dart';
import 'package:wp_chessboard/components/pieces.dart';
import 'package:wp_chessboard/components/shortcuts.dart';
import 'package:wp_chessboard/components/shortcuts/shortcut_highlight.dart';
import 'package:wp_chessboard/components/squares.dart';
import 'package:wp_chessboard/models/arrow.dart';
import 'package:wp_chessboard/models/arrow_list.dart';
import 'package:wp_chessboard/models/board_orientation.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'package:wp_chessboard/models/drop_indicator_args.dart';
import 'package:wp_chessboard/models/hint_map.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/piece_map.dart';
import 'package:wp_chessboard/models/shortcut_args.dart';
import 'package:wp_chessboard/models/square_info.dart';

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
  final bool turnTopPlayerPieces;
  final DropIndicatorArgs? dropIndicator;
  final ShortcutArgs? shortcuts;


  const WPChessboard({Key? key, required this.size, required this.squareBuilder, required this.pieceMap, required this.controller, this.onPieceTap, this.onPieceDrop, this.onEmptyFieldTap, this.onPieceStartDrag, this.orientation = BoardOrientation.white, this.ghostOnDrag = false, this.dropIndicator, this.turnTopPlayerPieces = false, this.shortcuts}) : super(key: key);

  @override
  State<WPChessboard> createState() => _WPChessboardState();
}

class _WPChessboardState extends State<WPChessboard> {
  ChessState state = ChessState("");
  HintMap hints = HintMap();
  ArrowList arrows = ArrowList([]);
  int? _selFile;
  int? _selRank;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _boardKey = GlobalKey();
  int _syntheticPointer = 0;

  @override
  void initState() {
    state = widget.controller.state;
    widget.controller.addListener(_controllerListener);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _clearSelection() {
    if (_selFile == null && _selRank == null) return;
    setState(() {
      _selFile = null;
      _selRank = null;
    });
  }

  void _commitSelection() {
    final int? file = _selFile;
    final int? rank = _selRank;
    if (file == null || rank == null) return;

    final RenderBox? box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final double squareSize = widget.size / 8;
    final Offset localCenter = Offset(
      (file - 1) * squareSize + squareSize / 2,
      (8 - rank) * squareSize + squareSize / 2,
    );
    final Offset globalCenter = box.localToGlobal(localCenter);

    setState(() {
      _selFile = null;
      _selRank = null;
    });

    _syntheticPointer++;
    GestureBinding.instance.handlePointerEvent(PointerDownEvent(
      pointer: _syntheticPointer,
      position: globalCenter,
    ));
    GestureBinding.instance.handlePointerEvent(PointerUpEvent(
      pointer: _syntheticPointer,
      position: globalCenter,
    ));
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final String? char = event.character?.toLowerCase();
    if (char == null || char.isEmpty) return KeyEventResult.ignored;

    final int code = char.codeUnitAt(0);
    const int aCode = 0x61; // 'a'
    const int hCode = 0x68; // 'h'
    const int oneCode = 0x31; // '1'
    const int eightCode = 0x38; // '8'

    if (code >= aCode && code <= hCode) {
      setState(() {
        _selFile = code - aCode + 1;
        _selRank = null;
      });
      return KeyEventResult.handled;
    }

    if (code >= oneCode && code <= eightCode) {
      if (_selFile == null) return KeyEventResult.ignored;
      final int rank = code - oneCode + 1;
      if (widget.shortcuts?.commitMode == ShortcutCommitMode.auto) {
        _selRank = rank;
        _commitSelection();
      } else {
        setState(() {
          _selRank = rank;
        });
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_selFile != null && _selRank != null) {
        _commitSelection();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  void _controllerListener() {
    if (state.fen != widget.controller.state.fen) {
      onUpdateState(widget.controller.state);
    }
    if (hints.id != widget.controller.hints.id) {
      onUpdateHints(widget.controller.hints);
    }
    if (arrows.id != widget.controller.arrows.id) {
      onUpdateArrows(widget.controller.arrows);
    }
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
    final bool shortcutsEnabled = widget.shortcuts != null;

    void Function(SquareInfo, String)? wrappedPieceTap = widget.onPieceTap;
    void Function(SquareInfo, String)? wrappedPieceStartDrag = widget.onPieceStartDrag;
    void Function(SquareInfo)? wrappedEmptyFieldTap = widget.onEmptyFieldTap;
    void Function(PieceDropEvent)? wrappedPieceDrop = widget.onPieceDrop;

    if (shortcutsEnabled) {
      wrappedPieceTap = (square, piece) {
        _clearSelection();
        widget.onPieceTap?.call(square, piece);
      };
      wrappedPieceStartDrag = (square, piece) {
        _clearSelection();
        widget.onPieceStartDrag?.call(square, piece);
      };
      wrappedEmptyFieldTap = (square) {
        _clearSelection();
        widget.onEmptyFieldTap?.call(square);
      };
      if (widget.onPieceDrop != null) {
        wrappedPieceDrop = (event) {
          _clearSelection();
          widget.onPieceDrop!(event);
        };
      }
    }

    final Widget board = Container(
      color: Colors.black,
      width: widget.size,
      height: widget.size,
      child: RotatedBox(
        quarterTurns: (widget.orientation == BoardOrientation.black) ? 2 : 0,
        child: Stack(
          key: _boardKey,
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
                turnTopPlayerPieces: widget.turnTopPlayerPieces,
                pieceMap: widget.pieceMap,
                state: state,
                onPieceTap: wrappedPieceTap,
                onPieceStartDrag: wrappedPieceStartDrag,
                onPieceDrop: wrappedPieceDrop,
                disableDrag: widget.onPieceDrop == null,
                ghostOnDrag: widget.ghostOnDrag,
                onEmptyFieldTap: wrappedEmptyFieldTap,
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

            if (shortcutsEnabled)
              Positioned.fill(
                child: ShortcutOverlay(
                  size: widget.size,
                  selFile: _selFile,
                  selRank: _selRank,
                  builder: widget.shortcuts!.highlightBuilder ?? (s) => ShortcutHighlight(size: s),
                ),
              ),

            Positioned.fill(
              child: Arrows(
                size: widget.size,
                arrows: arrows.value,
              ),
            ),

            Positioned.fill(
              // The drop itself is handled by the Draggable's onDragEnd in
              // Pieces (reliable on web); DropTargets is kept only for the
              // optional hover drop-indicator, so it must NOT also emit the drop
              // (that would double-fire onPieceDrop).
              child: DropTargets(
                size: widget.size,
                onPieceDrop: null,
                dropIndicator: widget.dropIndicator,
              ),
            ),
          ],
        ),
      )
    );

    if (!shortcutsEnabled) {
      return board;
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _focusNode.requestFocus(),
        child: board,
      ),
    );
  }
}

class WPChessboardController extends ChangeNotifier {
  ChessState state = ChessState("");
  HintMap hints = HintMap();
  ArrowList arrows = ArrowList([]);
  bool shouldAnimate = true;

  WPChessboardController({ initialFen = "" }) {
    state = ChessState(initialFen);
  }

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
