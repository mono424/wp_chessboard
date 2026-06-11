# wp_chessboard — SolidJS example

A [SolidJS](https://www.solidjs.com/) wrapper around the Flutter `wp_chessboard`
web build, mirroring the [`react_example`](../react_example). The reusable
component lives in [`src/wp_chessboard/wp_chessboard.jsx`](src/wp_chessboard/wp_chessboard.jsx).

## How it works

The chessboard itself is the Flutter app compiled to web. The Solid component
loads that build into a host `<div>` via the `_flutter` loader (the loader is
pulled in by `<script src="/flutter/flutter.js">` in `index.html`), waits for the
`flutter-initialized` event to receive the Flutter `StateManager`, and then keeps
the board in sync with its props.

## Getting started

1. **Build the Flutter web assets** (requires the Flutter SDK). From the repo root:

   ```bash
   cd web_example
   ./build.sh
   ```

   This runs `flutter build web` and copies the output into
   `solid_example/public/flutter` (and `react_example/public/flutter`). After it
   finishes you should have `solid_example/public/flutter/flutter.js` and
   `solid_example/public/flutter/main.dart.js`. This folder is gitignored — it is
   regenerated from the Flutter build.

2. **Install dependencies and run the dev server:**

   ```bash
   cd solid_example
   npm install
   npm run dev
   ```

   Open http://localhost:3000.

3. **Production build:** `npm run build` (output in `dist/`), preview with
   `npm run serve`.

## Usage

```jsx
import WPChessboard from "./wp_chessboard/wp_chessboard";

<WPChessboard
  src="/flutter/main.dart.js"
  assetBase="/flutter/"
  size={600}
  fen="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  orientation={true}
  lightColor="#f0d9b5"
  darkColor="#b58863"
  didLoad={() => console.log("loaded")}
  onFenChanged={(fen) => console.log("fen", fen)}
/>;
```

### Props

| Prop           | Type                       | Description                                              |
| -------------- | -------------------------- | -------------------------------------------------------- |
| `src`          | `string`                   | URL of the Flutter entrypoint, e.g. `/flutter/main.dart.js`. |
| `assetBase`    | `string`                   | Base path for Flutter assets, e.g. `/flutter/`.          |
| `size`         | `number`                   | Board size in pixels.                                    |
| `fen`          | `string`                   | FEN string describing the position.                      |
| `orientation`  | `boolean`                  | Board orientation (flips the view).                      |
| `lightColor`   | `string`                   | CSS color for the light squares.                         |
| `darkColor`    | `string`                   | CSS color for the dark squares.                          |
| `didLoad`      | `() => void`               | Called once when the board has initialized.              |
| `onFenChanged` | `(fen: string) => void`    | Called whenever the board's FEN changes.                 |
