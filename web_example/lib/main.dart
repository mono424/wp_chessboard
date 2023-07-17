import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';
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

const watermarkSquare = ["d5", "e4"];

Widget Function(SquareInfo) createSquareBuilder(Color light, Color dark, String watermarkAsset, double watermarkOpacity) {
  final watermarkAvailable = watermarkAsset != "";
  final watermark = watermarkAvailable ? Opacity(opacity: watermarkOpacity, child: Image.asset(watermarkAsset)) : const SizedBox();

  return (SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0 ? light : dark;
    Color overlayColor = Colors.transparent;

    bool showWatermark = watermarkAvailable && watermarkSquare.contains(info.toString());

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
        child: showWatermark ? Center(
          child: Padding(
            padding: EdgeInsets.all(info.size / 8),
            child: watermark,
          ),
        ) : null
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
  final ValueNotifier<bool> _watermarkVisible = ValueNotifier<bool>(true);
  final ValueNotifier<double> _watermarkOpacity = ValueNotifier<double>(0.34);
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
      watermarkVisible: _watermarkVisible,
      watermarkOpacity: _watermarkOpacity
    );
    final export = createDartExport(_state);
    broadcastAppEvent('flutter-initialized', export);
    listenToState();
  }

  void listenToState() {
    _fen.addListener(() {
      update(_fen.value);
    });
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    
  }

  void onPieceTap(SquareInfo square, String piece) {
    
  }
  
  void showHintFields(SquareInfo square, String piece) {
    
  }

  void onEmptyFieldTap(SquareInfo square) {
    
  }

  void onPieceDrop(PieceDropEvent event) {
    
  }

  void update(String fen, {bool animated = true}) {
    controller.setFen(fen, animation: animated);
  }

  void addArrows() {
    controller.setArrows([
      Arrow(
        from: SquareLocation.fromString("b1"),
        to: SquareLocation.fromString("c3"),
      ),
      Arrow(
        from: SquareLocation.fromString("g1"),
        to: SquareLocation.fromString("f3"),
        color: Colors.red
      )
    ]);
  }

  void removeArrows() {
    controller.setArrows([]);
  }

  BoardOrientation orienatation = BoardOrientation.white;
  void toggleArrows() {
    setState(() {
      if (orienatation == BoardOrientation.white) {
        orienatation = BoardOrientation.black;
      } else {
        orienatation = BoardOrientation.white;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AnimatedBuilder(
        animation: Listenable.merge([_size, _lightColor, _darkColor, _orientation]),
        builder: (context, _) => WPChessboard(
          size: _size.value,
          orientation: _orientation.value ? BoardOrientation.black : BoardOrientation.white,
          squareBuilder: createSquareBuilder(
            HexColor.fromHex(_lightColor.value),
            HexColor.fromHex(_darkColor.value),
            _watermarkVisible.value ? "assets/watermark.png" : "",
            _watermarkOpacity.value,
          ),
          controller: controller,
          // Dont pass any onPieceDrop handler to disable drag and drop
          // onPieceDrop: onPieceDrop,
          // onPieceTap: onPieceTap,
          // onPieceStartDrag: onPieceStartDrag,
          // onEmptyFieldTap: onEmptyFieldTap,
          turnTopPlayerPieces: false,
          ghostOnDrag: true,
          // dropIndicator: DropIndicatorArgs(
          //   size: value / 2,
          //   color: Colors.lightBlue.withOpacity(0.24)
          // ),
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
      ),
    );
  }
}
