import type { PieceChar, Square } from "./types";

export type BoardArray = (PieceChar | "")[];

export function squareToIndex(square: Square): number {
  const file = square.charCodeAt(0) - 97;
  const rank = square.charCodeAt(1) - 49;
  return rank * 8 + file;
}

export function indexToSquare(index: number): Square {
  const file = index % 8;
  const rank = Math.floor(index / 8);
  return String.fromCharCode(97 + file) + (rank + 1);
}

/**
 * Parse the placement field of a FEN into a flat 64 array indexed
 * rank*8+file (a1 = 0, bottom-up — same layout as the Dart ChessState).
 */
export function parseBoard(fen: string): BoardArray {
  const board: BoardArray = new Array(64).fill("");
  if (fen === "") return board;

  const placement = fen.split(" ")[0]!;
  const fenRanks = placement.split("/");
  for (let i = 0; i < fenRanks.length && i < 8; i++) {
    const rank = 7 - i;
    let file = 0;
    const row = fenRanks[i]!;
    for (const ch of row) {
      if (ch >= "1" && ch <= "8") {
        file += ch.charCodeAt(0) - 48;
      } else if (file < 8) {
        board[rank * 8 + file] = ch as PieceChar;
        file++;
      }
    }
  }
  return board;
}

/**
 * Find the square a piece came from: empty in `next` but held `piece` in
 * `prev`. Scan order matches the Dart implementation (rank 8 down to 1,
 * files a to h) so animation origins are identical.
 */
export function findFrom(
  prev: BoardArray,
  next: BoardArray,
  piece: PieceChar,
): number | null {
  for (let rank = 7; rank >= 0; rank--) {
    for (let file = 0; file < 8; file++) {
      const i = rank * 8 + file;
      if (next[i] === "" && prev[i] === piece) return i;
    }
  }
  return null;
}

export interface RenderPiece {
  index: number;
  square: Square;
  piece: PieceChar;
  /** Square the piece slides in from, or null for no animation. */
  fromIndex: number | null;
  key: string;
}

/**
 * Occupied squares of `fen`, each with the origin square to animate from
 * (when the piece was added or replaced relative to `prevFen`).
 */
export function computeRenderList(
  prevFen: string | null,
  fen: string,
): RenderPiece[] {
  const next = parseBoard(fen);
  const prev = prevFen === null ? null : parseBoard(prevFen);
  const list: RenderPiece[] = [];

  for (let i = 0; i < 64; i++) {
    const piece = next[i]!;
    if (piece === "") continue;
    let fromIndex: number | null = null;
    if (prev !== null && prev[i] !== piece) {
      fromIndex = findFrom(prev, next, piece);
    }
    list.push({
      index: i,
      square: indexToSquare(i),
      piece,
      fromIndex,
      key: `${fen}#${i}#${piece}`,
    });
  }
  return list;
}
