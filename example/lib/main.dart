import 'package:chess/chess.dart' as Chess;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/components/hints/move_hint.dart';
import 'package:wp_chessboard/models/hint_map.dart';
import 'package:wp_chessboard/models/piece_drop_event.dart';
import 'package:wp_chessboard/models/piece_map.dart';
import 'package:wp_chessboard/models/square_info.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = WPChessboardController();
  Chess.Chess chess = Chess.Chess();

  Widget squareBuilder(SquareInfo info) {
    return Container(
      color: (info.index + info.rank) % 2 == 0 ? Colors.grey.shade200 : Colors.grey.shade600,
      width: info.size,
      height: info.size,
    );
  }

  void onPieceTap(SquareInfo square, String piece) {
    final moves = chess.generate_moves({ 'square': square.toString() });
    final hintMap = HintMap();
    for (var move in moves) {
      String to = move.toAlgebraic;
      int rank = to.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

      hintMap.set(rank, file, (size) => MoveHint(
        size: size,
        onPressed: () => doMove(move),
      ));
    }
    controller.setHints(hintMap);
  }

  void onEmptyFieldTap(SquareInfo square) {
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) {
    chess.move({ "from": event.from.toString(), "to": event.to.toString() });
    update();
  }

  void doMove(Chess.Move move) {
    chess.move(move);
    update();
  }

  void setDefaultFen() {
    setState(() {
      chess = Chess.Chess.fromFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1");
    });
    update();
  }

  void setRandomFen() {
    setState(() {
      chess = Chess.Chess.fromFEN("3bK3/4B1P1/3p2N1/1rp3P1/2p2p2/p3n3/P5k1/6q1 w - - 0 1");
    });
    update();
  }

  void update() {
    controller.setFen(chess.fen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WPChessboard Demo',
      home: Scaffold(
        body: Builder(builder: (context) {
            final double size = MediaQuery.of(context).size.shortestSide;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WPChessboard(
                  size: size,
                  squareBuilder: squareBuilder,
                  controller: controller,
                  onPieceDrop: onPieceDrop,
                  onPieceTap: onPieceTap,
                  onEmptyFieldTap: onEmptyFieldTap,
                  pieceMap: PieceMap(
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
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: setDefaultFen,
                  child: const Text("Set default Fen"),
                ),
                TextButton(
                  onPressed: setRandomFen,
                  child: const Text("Set random Fen"),
                )
              ],
            );
          },
        )
      )
    );
  }
}
