import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wp_chessboard/components/arrows.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

void main() {
  testWidgets('paints arrows of any width and opacity', (tester) async {
    final controller = WPChessboardController(initialFen: '8/8/8/8/8/8/8/8');
    Widget b(double size) => SizedBox(width: size, height: size);
    await tester.pumpWidget(MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: WPChessboard(
          size: 400,
          controller: controller,
          squareBuilder: (info) => SizedBox(width: info.size, height: info.size),
          pieceMap: PieceMap(K: b, Q: b, B: b, N: b, R: b, P: b, k: b, q: b, b: b, n: b, r: b, p: b),
        ),
      ),
    ));
    controller.setArrows([
      Arrow(from: SquareLocation.fromString('e2'), to: SquareLocation.fromString('e4')),
      Arrow(
        from: SquareLocation.fromString('g1'),
        to: SquareLocation.fromString('f3'),
        color: const Color(0x801B5E20),
        width: 9,
      ),
      Arrow(
        from: SquareLocation.fromString('b1'),
        to: SquareLocation.fromString('c3'),
        color: const Color(0x4DFFA000),
        width: 2,
      ),
    ]);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Arrows), findsOneWidget);
  });
}
