import 'dart:js_interop';

import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';
import 'package:wp_chessboard/models/chess_state.dart';
import 'src/js_interop.dart';

void main() {
  runApp(const MyApp());
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

Widget Function(SquareInfo) createSquareBuilder(Color light, Color dark) {
  return (SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0 ? light : dark;
    Color overlayColor = Colors.transparent;

    // if (lastMove != null ) {
    //   if (lastMove!.first.first == info.rank && lastMove!.first.last == info.file) {
    //     overlayColor = Colors.blueAccent.shade400.withOpacity(0.4);
    //   } else if (lastMove!.last.first == info.rank && lastMove!.last.last == info.file) {
    //     overlayColor = Colors.blueAccent.shade400.withOpacity(0.87);
    //   }
    // }

    return Container(
      color: fieldColor,
      width: info.size,
      height: info.size,
      child: AnimatedContainer(
        color: overlayColor,
        width: info.size,
        height: info.size,
        duration: const Duration(milliseconds: 200),
      )
    );
  };
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StateManager _state;
  final ValueNotifier<String> _fen = ValueNotifier<String>('');
  final ValueNotifier<String> _lightColor = ValueNotifier<String>(Colors.grey.shade200.toHex());
  final ValueNotifier<String> _darkColor = ValueNotifier<String>(Colors.grey.shade600.toHex());
  final ValueNotifier<double> _size= ValueNotifier<double>(400);
  final ValueNotifier<bool> _orientation= ValueNotifier<bool>(false);
  final ValueNotifier<bool> _interactive = ValueNotifier<bool>(false);
  final ValueNotifier<String> _move = ValueNotifier<String>('');
  final ValueNotifier<String> _tap = ValueNotifier<String>('');
  final ValueNotifier<String> _hints = ValueNotifier<String>('');
  final ValueNotifier<String> _arrows = ValueNotifier<String>('');
  // Whether setFen animates the piece move (slide) or snaps. Analysis/display
  // hosts set this false via StateManager.setAnimated to avoid per-move animation
  // repaints when stepping through a game. Defaults to true (e.g. puzzle play).
  final ValueNotifier<bool> _animate = ValueNotifier<bool>(true);
  int _moveSeq = 0;
  int _tapSeq = 0;
  final controller = WPChessboardController();

  @override
  void initState() {
    super.initState();
    _state = StateManager(
      fen: _fen,
      size: _size,
      lightColor: _lightColor,
      darkColor: _darkColor,
      orientation: _orientation,
      interactive: _interactive,
      move: _move,
      tap: _tap,
      hints: _hints,
      arrows: _arrows,
      animate: _animate,
    );
    // Attach the listeners BEFORE broadcasting: the host (e.g. a SolidJS/React
    // wrapper) reacts to `flutter-initialized` synchronously and may call setFen
    // immediately. If the listener isn't attached yet, that first FEN sets
    // `_fen.value` but never reaches the board → an empty board.
    listenToState();
    final export = createJSInteropWrapper(_state);
    broadcastAppEvent('flutter-initialized', export);
  }

  void listenToState() {
    _fen.addListener(() {
      update(_fen.value, animated: _animate.value);
    });
    // JS pushes selection + legal-move targets here; render them as board hints.
    _hints.addListener(() {
      renderHints(_hints.value);
    });
    // JS pushes arrows here (e.g. engine candidate moves); render them on top.
    _arrows.addListener(() {
      renderArrows(_arrows.value);
    });
  }

  // Report a drag (from→to) to JS as "<from><to>#<seq>" (absolute algebraic
  // a1..h8). JS validates with chess.js and pushes the result back via setFen.
  void emitMove(SquareInfo from, SquareInfo to) {
    _move.value = '${from}${to}#${++_moveSeq}';
  }

  // Report a single tap on a square. JS owns selection + chess logic and decides
  // whether the tap selects a piece (then pushes hints) or completes a move.
  void emitTap(SquareInfo square) {
    _tap.value = '${square}#${++_tapSeq}';
  }

  // Render JS-provided hints: "<selected>|<csv targets>" → a fill on the selected
  // square and a move dot on each legal target. The Hints layer positions by
  // logical (rank,file), so this is orientation-correct.
  void renderHints(String value) {
    final hints = HintMap();
    final parts = value.split('|');
    final selected = parts.isNotEmpty ? parts[0] : '';
    final targets = parts.length > 1 ? parts[1] : '';
    if (selected.isNotEmpty) {
      final loc = SquareLocation.fromString(selected);
      hints.set(loc.rank, loc.file, (size) => Container(
        width: size,
        height: size,
        color: const Color(0x99F4C542),
      ));
    }
    for (final t in targets.split(',')) {
      if (t.isEmpty) continue;
      final loc = SquareLocation.fromString(t);
      hints.set(loc.rank, loc.file, (size) => MoveHint(size: size, color: const Color(0x66000000)));
    }
    controller.setHints(hints);
  }

  void update(String fen, {bool animated = true}) {
    controller.setFen(fen, animation: animated);
  }

  // Render JS-provided arrows: a comma-separated list of "<from><to>[:<AARRGGBB>]"
  // entries (e.g. "e2e4:ff5e6ad2,d2d4:805e6ad2"). Each entry is two squares plus
  // an optional 8-digit ARGB hex color (defaults to green). Empty → no arrows.
  void renderArrows(String value) {
    final arrows = <Arrow>[];
    for (final entry in value.split(',')) {
      if (entry.length < 4) continue;
      final from = entry.substring(0, 2);
      final to = entry.substring(2, 4);
      final colon = entry.indexOf(':');
      final hex = colon >= 0 ? entry.substring(colon + 1) : '';
      arrows.add(Arrow(
        from: SquareLocation.fromString(from),
        to: SquareLocation.fromString(to),
        color: hex.isNotEmpty ? HexColor.fromHex(hex) : Colors.green,
      ));
    }
    controller.setArrows(arrows);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AnimatedBuilder(
        // _fen is included so InteractiveBoard always sees the current position
        // (it reads the piece under the pointer from the FEN).
        animation: Listenable.merge([_fen, _size, _lightColor, _darkColor, _orientation, _interactive]),
        builder: (context, _) {
          // The board is display-only (no Draggable / tap handlers): Flutter's
          // Draggable+DragTarget drop detection is unreliable on web. Interaction
          // is layered on top via InteractiveBoard, which uses raw pointer events.
          final board = WPChessboard(
            size: _size.value,
            orientation: _orientation.value ? BoardOrientation.black : BoardOrientation.white,
            squareBuilder: createSquareBuilder(
              HexColor.fromHex(_lightColor.value),
              HexColor.fromHex(_darkColor.value),
            ),
            controller: controller,
            turnTopPlayerPieces: false,
            ghostOnDrag: true,
            pieceMap: buildPieceMap(),
          );
          if (!_interactive.value) return board;
          return InteractiveBoard(
            size: _size.value,
            blackOrientation: _orientation.value,
            fen: _fen.value,
            pieceMap: buildPieceMap(),
            onMove: emitMove,
            onTap: emitTap,
            child: board,
          );
        },
      ),
    );
  }
}

PieceMap buildPieceMap() => PieceMap(
      K: (size) => WhiteKing(size: size),
      Q: (size) => WhiteQueen(size: size),
      B: (size) => WhiteBishop(size: size),
      N: (size) => WhiteKnight(size: size),
      R: (size) => WhiteRook(size: size),
      P: (size) => WhitePawn(size: size),
      k: (size) => BlackKing(size: size),
      q: (size) => BlackQueen(size: size),
      b: (size) => BlackBishop(size: size),
      n: (size) => BlackKnight(size: size),
      r: (size) => BlackRook(size: size),
      p: (size) => BlackPawn(size: size),
    );

// Raw-pointer interaction layer over the (display-only) board. Maps pointer
// positions to squares (orientation-aware), shows a piece that follows the
// cursor while dragging, and reports drags (onMove) and taps (onTap). Using a
// Listener — rather than Flutter's Draggable — makes drag work reliably with a
// real mouse on the web renderer.
class InteractiveBoard extends StatefulWidget {
  final double size;
  final bool blackOrientation;
  final String fen;
  final PieceMap pieceMap;
  final void Function(SquareInfo from, SquareInfo to) onMove;
  final void Function(SquareInfo square) onTap;
  final Widget child;

  const InteractiveBoard({
    Key? key,
    required this.size,
    required this.blackOrientation,
    required this.fen,
    required this.pieceMap,
    required this.onMove,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  @override
  State<InteractiveBoard> createState() => _InteractiveBoardState();
}

class _InteractiveBoardState extends State<InteractiveBoard> {
  static const double _dragSlop = 6.0;

  SquareInfo? _downSquare;
  String _downPiece = '';
  Offset _downPos = Offset.zero;
  Offset? _dragPos; // non-null once a drag is underway (board-local coords)

  double get _sq => widget.size / 8;

  SquareInfo _squareAt(Offset local) {
    final int col = (local.dx / _sq).floor().clamp(0, 7).toInt();
    final int rowFromTop = (local.dy / _sq).floor().clamp(0, 7).toInt();
    final int file = widget.blackOrientation ? 7 - col : col;
    final int rank = widget.blackOrientation ? rowFromTop : 7 - rowFromTop;
    return SquareInfo(rank * 8 + file, _sq);
  }

  String _pieceAt(SquareInfo sq) => ChessState(widget.fen).getEntry(sq.rank, sq.file).piece;

  void _onDown(PointerDownEvent e) {
    final sq = _squareAt(e.localPosition);
    _downSquare = sq;
    _downPos = e.localPosition;
    _downPiece = _pieceAt(sq);
    _dragPos = null;
  }

  void _onMove(PointerMoveEvent e) {
    if (_downSquare == null || _downPiece.isEmpty) return;
    if (_dragPos == null && (e.localPosition - _downPos).distance < _dragSlop) return;
    setState(() => _dragPos = e.localPosition);
  }

  void _onUp(PointerUpEvent e) {
    final from = _downSquare;
    final wasDragging = _dragPos != null;
    if (from != null) {
      if (wasDragging) {
        final to = _squareAt(e.localPosition);
        if (to.index != from.index) {
          widget.onMove(from, to);
        }
      } else {
        widget.onTap(from);
      }
    }
    setState(() {
      _downSquare = null;
      _downPiece = '';
      _dragPos = null;
    });
  }

  void _onCancel(PointerCancelEvent e) {
    setState(() {
      _downSquare = null;
      _downPiece = '';
      _dragPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: Stack(
        children: [
          widget.child,
          if (_dragPos != null && _downPiece.isNotEmpty)
            Positioned(
              left: _dragPos!.dx - _sq / 2,
              top: _dragPos!.dy - _sq / 2,
              child: IgnorePointer(child: widget.pieceMap.get(_downPiece)(_sq)),
            ),
        ],
      ),
    );
  }
}
