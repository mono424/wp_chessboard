# WP_CHESSBOARD

![Chessboard](https://github.com/mono424/wp_chessboard/blob/main/images/board.png?raw=true)

A very customizable Chessboard with awesomeness already onboard:

👇️ Dragable Pieces

🎬️ Move Animations

🔄 Orientation

💡 Hints

💡 Arrows

## Features

### 🎬️ Piece Animations for Single Moves

![Animate-Single](https://github.com/mono424/wp_chessboard/blob/main/images/animate-single.gif?raw=true)

### 🎬️ Piece Animations for position changes/reset

![Animate-Many](https://github.com/mono424/wp_chessboard/blob/main/images/animate-many.gif?raw=true)

### 🔄 Change Orientation

![Board-Orientation](https://github.com/mono424/wp_chessboard/blob/main/images/board-orientation.png?raw=true)

### 💡 Display Hints

![Hints](https://github.com/mono424/wp_chessboard/blob/main/images/hints.gif?raw=true)

### 💡 Display Arrows

![Board-Arrows](https://github.com/mono424/wp_chessboard/blob/main/images/board-arrows.png?raw=true)


## Usage

First import the `WPChessboard` widget and the `PieceMap` class.
```dart
import 'package:wp_chessboard/wp_chessboard.dart';
import 'package:wp_chessboard/models/piece_map.dart';
```

Then, you are ready to use it

> You can use your own piece set, in the example we will
> use the `chess_vectors_flutter` package.

```dart
WPChessboard(
    size: size,
    squareBuilder: squareBuilder,
    controller: controller,
    onPieceDrop: onPieceDrop,
    onPieceTap: onPieceTap,
    onPieceStartDrag: onPieceStartDrag,
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
```

I know this is very short, for more information checkout the example :).

## Additional information

Every contribution is very welcome.

Cheers 🥂
