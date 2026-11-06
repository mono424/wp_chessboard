import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

// The per-square piece builder: what it is given and how the board places what
// it returns.
void main() {
  const start = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR';
  const afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR';

  PieceMap pieceMap() {
    Widget b(double size) => SizedBox(key: const ValueKey('stock'), width: size, height: size);
    return PieceMap(K: b, Q: b, B: b, N: b, R: b, P: b, k: b, q: b, b: b, n: b, r: b, p: b);
  }

  Future<WPChessboardController> pump(
    WidgetTester tester, {
    required SquarePieceBuilder? builder,
    BoardOrientation orientation = BoardOrientation.white,
    bool turnTopPlayerPieces = false,
    bool draggable = false,
  }) async {
    final controller = WPChessboardController(initialFen: start);
    await tester.pumpWidget(MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: WPChessboard(
          size: 400,
          controller: controller,
          orientation: orientation,
          turnTopPlayerPieces: turnTopPlayerPieces,
          squareBuilder: (info) => SizedBox(width: info.size, height: info.size),
          pieceMap: pieceMap(),
          pieceBuilder: builder,
          onPieceDrop: draggable ? (_) {} : null,
        ),
      ),
    ));
    return controller;
  }

  testWidgets('null draws the piece map, a widget replaces it', (tester) async {
    await pump(tester, builder: (args) {
      if (args.square.toString() != 'e2') return null;
      return SquarePiece(SizedBox(key: const ValueKey('skin'), width: args.size, height: args.size));
    });
    expect(find.byKey(const ValueKey('skin')), findsOneWidget);
    expect(find.byKey(const ValueKey('stock')), findsNWidgets(31));
    expect(tester.getTopLeft(find.byKey(const ValueKey('skin'))), const Offset(200, 300));
  });

  testWidgets('a moved piece is told where it came from, in its own frame', (tester) async {
    for (final (orientation, turn, expected) in [
      (BoardOrientation.white, false, const Offset(0, 100)),
      (BoardOrientation.black, false, const Offset(0, -100)),
      // White is the top player here, and its pieces are turned around.
      (BoardOrientation.black, true, const Offset(0, 100)),
    ]) {
      final seen = <String, PieceSquareArgs>{};
      final controller = await pump(
        tester,
        orientation: orientation,
        turnTopPlayerPieces: turn,
        builder: (args) {
          seen[args.square.toString()] = args;
          return null;
        },
      );
      expect(seen['e2']!.from, isNull);
      expect(seen['e2']!.moved, isFalse);
      controller.setFen(afterE4);
      await tester.pump();
      final e4 = seen['e4']!;
      expect(e4.piece, 'P');
      expect(e4.from.toString(), 'e2');
      expect(e4.fromOffset, expected, reason: '$orientation turn=$turn');
      expect(e4.moved, isTrue);
      expect(seen['d2']!.from, isNull, reason: 'a pawn that stayed put');
      controller.setFen(start, animation: false);
      await tester.pump();
      expect(seen['e2']!.from, isNull, reason: 'no animation, nothing moved');
      await tester.pumpAndSettle();
      // The next board starts from scratch.
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a piece that owns its travel is placed at once, over the others', (tester) async {
    final controller = await pump(tester, builder: (args) {
      if (args.piece != 'P') return null;
      return SquarePiece(
        SizedBox(key: ValueKey('pawn-${args.square}'), width: args.size, height: args.size),
        ownsTravel: true,
      );
    });
    controller.setFen(afterE4);
    await tester.pump();
    await tester.pump();
    final pawn = find.byKey(const ValueKey('pawn-e4'));
    expect(tester.getTopLeft(pawn), const Offset(200, 200), reason: 'no 200 ms slide');
    // Drawn last: the moving piece passes over the pieces it crosses.
    final stack = tester.widget<Stack>(find.ancestor(of: pawn, matching: find.byType(Stack)).first);
    final last = stack.children.last;
    expect(find.descendant(of: find.byWidget(last), matching: pawn), findsOneWidget);

    // A piece that did not move slides as before when the board animates.
    controller.setFen(start);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final midway = tester.getTopLeft(find.byKey(const ValueKey('pawn-e2')));
    expect(midway, const Offset(200, 300), reason: 'the travelling pawn is already home');
    await tester.pumpAndSettle();
  });

  testWidgets('a builder piece without ownsTravel still slides', (tester) async {
    final controller = await pump(tester, builder: (args) {
      if (args.piece != 'P') return null;
      return SquarePiece(SizedBox(key: ValueKey('pawn-${args.square}'), width: args.size, height: args.size));
    });
    controller.setFen(afterE4);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final dy = tester.getTopLeft(find.byKey(const ValueKey('pawn-e4'))).dy;
    expect(dy, greaterThan(200));
    expect(dy, lessThan(300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('pawn-e4'))), const Offset(200, 200));
  });

  testWidgets('the drag feedback is asked for separately', (tester) async {
    final feedback = <String>[];
    await pump(tester, draggable: true, builder: (args) {
      if (args.square.toString() != 'e2') return null;
      if (args.dragFeedback) feedback.add(args.square.toString());
      return SquarePiece(SizedBox(width: args.size, height: args.size));
    });
    expect(feedback, ['e2']);
    expect(tester.takeException(), isNull);
  });
}
