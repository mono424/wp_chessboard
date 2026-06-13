import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

// Verifies the drag-to-move path: dragging a piece fires onPieceDrop with the
// correct from/to squares. The drop is resolved by the Draggable's onDragEnd
// (mapping the release position back to a square), so this exercises that logic
// including the board's orientation RotatedBox.
void main() {
  PieceMap buildPieceMap() {
    Widget b(double size) => Container(width: size, height: size, color: const Color(0xFF888888));
    return PieceMap(K: b, Q: b, B: b, N: b, R: b, P: b, k: b, q: b, b: b, n: b, r: b, p: b);
  }

  Future<PieceDropEvent?> doDrag(
    WidgetTester tester, {
    required BoardOrientation orientation,
    required Offset from,
    required Offset moveBy,
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) async {
    PieceDropEvent? dropped;
    final controller = WPChessboardController(
      initialFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR',
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: WPChessboard(
            size: 400,
            controller: controller,
            orientation: orientation,
            squareBuilder: (info) => SizedBox(width: info.size, height: info.size),
            pieceMap: buildPieceMap(),
            onPieceDrop: (e) => dropped = e,
          ),
        ),
      ),
    ));
    await tester.pump();
    final TestGesture gesture = await tester.startGesture(from, kind: kind, buttons: kPrimaryButton);
    await tester.pump(const Duration(milliseconds: 20));
    const steps = 12;
    for (int i = 1; i <= steps; i++) {
      await gesture.moveBy(Offset(moveBy.dx / steps, moveBy.dy / steps));
      await tester.pump(const Duration(milliseconds: 8));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    return dropped;
  }

  // size=400 → squareSize=50. White view: a1 bottom-left. Square centre (file
  // 0..7 left→right, rank 1..8): x=(file+0.5)*50, y=(8-rank+0.5)*50.
  testWidgets('white: drag e2 -> e4 fires onPieceDrop(e2,e4)', (tester) async {
    final d = await doDrag(
      tester,
      orientation: BoardOrientation.white,
      from: const Offset(225, 325), // e2 centre
      moveBy: const Offset(0, -100), // up two ranks → e4
    );
    expect(d, isNotNull, reason: 'onPieceDrop should fire on drag end');
    expect(d!.from.toString(), 'e2');
    expect(d.to.toString(), 'e4');
  });

  testWidgets('white: drag g1 -> f3 fires onPieceDrop(g1,f3)', (tester) async {
    final d = await doDrag(
      tester,
      orientation: BoardOrientation.white,
      from: const Offset(325, 375), // g1 centre (file 6, rank 1)
      moveBy: const Offset(-50, -100), // → f3 (file 5, rank 3)
    );
    expect(d, isNotNull);
    expect(d!.from.toString(), 'g1');
    expect(d.to.toString(), 'f3');
  });

  // The real-world case: a MOUSE drag (what users do on web/desktop).
  testWidgets('MOUSE: drag e2 -> e4 fires onPieceDrop(e2,e4)', (tester) async {
    final d = await doDrag(
      tester,
      orientation: BoardOrientation.white,
      from: const Offset(225, 325),
      moveBy: const Offset(0, -100),
      kind: PointerDeviceKind.mouse,
    );
    expect(d, isNotNull, reason: 'mouse drag should fire onPieceDrop');
    expect(d!.from.toString(), 'e2');
    expect(d.to.toString(), 'e4');
  });
}
