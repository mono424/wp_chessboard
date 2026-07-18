# wp-chessboard-solid

Web-native SolidJS chessboard — a DOM/SVG port of the
[`wp_chessboard`](https://pub.dev/packages/wp_chessboard) Flutter widget.
No wasm, no canvas, no runtime dependencies. **~7.4 KB gzipped** including
the bundled piece set (the Flutter web embedding it replaces ships ~1.6 MB
of app JS plus a multi-megabyte CanvasKit wasm).

## Install

```sh
npm install wp-chessboard-solid solid-js
```

## Usage

```jsx
import { WPChessboard } from "wp-chessboard-solid";

function App() {
  const [fen, setFen] = createSignal(
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  );

  return (
    <WPChessboard
      fen={fen()}
      size={600}
      lightColor="#f0d9b5"
      darkColor="#b58863"
      interactive
      onMove={({ from, to }) => {
        // validate with your chess engine of choice, then:
        setFen(nextFen);
      }}
    />
  );
}
```

The component is fully controlled: it never mutates the position itself.
Handle `onMove`/`onTap`, validate the move (e.g. with
[chess.js](https://github.com/jhlywa/chess.js)), and set the new `fen` —
pieces slide to their new squares with a 200 ms animation derived from the
FEN diff, exactly like the Flutter widget.

## Props

| Prop | Type | Default | Description |
| --- | --- | --- | --- |
| `fen` | `string` | — | Position (placement field is enough) |
| `size` | `number` | `400` | Board edge length in px |
| `orientation` | `"white" \| "black" \| boolean` | `"white"` | `true` = black at bottom (legacy compat) |
| `lightColor` / `darkColor` | `string` | `#EEEEEE` / `#757575` | Square colors |
| `interactive` | `boolean` | `false` | Enable tap + drag input |
| `animated` | `boolean` | `true` | Animate piece slides on fen change |
| `animationDurationMs` | `number` | `200` | Slide duration |
| `moveHints` | `{ selected?, targets? }` | — | Selected-square fill + move-target dots |
| `arrows` | `{ from, to, color? }[]` | — | Arrows drawn over the board |
| `ghostOnDrag` | `boolean` | `false` | Show origin piece at 20% opacity while dragging |
| `dropIndicator` | `boolean \| { color? }` | off | Highlight hovered square while dragging |
| `shortcuts` | `boolean \| { commitMode?, highlightColor? }` | off | Keyboard square selection: `a`–`h`, `1`–`8`, space commits (`commitMode: "auto"` commits on the digit) |
| `turnTopPlayerPieces` | `boolean` | `false` | Rotate the top player's pieces 180° |
| `pieces` | `Partial<Record<PieceChar, (size) => JSX.Element>>` | cburnett | Per-piece renderer overrides |
| `renderSquare` | `(info: SquareInfo) => JSX.Element` | — | Custom square renderer |

Events: `onMove({from, to, piece})`, `onTap({square, piece})`,
`onPieceTap`, `onEmptyFieldTap`, `onPieceStartDrag`, `onFenChanged(fen)`.

Piece components (`WhiteKing` … `BlackPawn`) and `defaultPieceMap` are
exported for reuse; FEN helpers `parseBoard`, `squareToIndex`,
`indexToSquare` too.

## Development

```sh
npm install
npm test        # vitest unit tests (fen diff, coords)
npm run build   # dist/index.js (ESM) + .d.ts
```

The package ships raw `.tsx` source under the `"solid"` export condition, so
Solid-aware bundlers (`vite-plugin-solid`) compile it with your app for full
reactivity; other tools use the compiled ESM in `dist/`.

## License

Code: MIT (same as the parent repo).

Piece graphics: the [cburnett chess set](https://en.wikipedia.org/wiki/User:Cburnett/GFDL_images/Chess)
by Colin M.L. Burnett, licensed CC-BY-SA 3.0 (via
[lichess-org/lila](https://github.com/lichess-org/lila/tree/master/public/piece/cburnett)).
