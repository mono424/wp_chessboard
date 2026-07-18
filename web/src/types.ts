import type { JSX } from "solid-js";

export type PieceChar =
  | "K" | "Q" | "R" | "B" | "N" | "P"
  | "k" | "q" | "r" | "b" | "n" | "p";

/** Algebraic square name, "a1".."h8". */
export type Square = string;

export type PieceRenderer = (size: number) => JSX.Element;

export interface SquareInfo {
  /** 0..63, a1 = 0, h1 = 7, a8 = 56. */
  index: number;
  /** 0..7 (a = 0). */
  file: number;
  /** 0..7 (rank 1 = 0). */
  rank: number;
  square: Square;
  size: number;
}

export interface Arrow {
  from: Square;
  to: Square;
  color?: string;
}

export interface MoveHints {
  selected?: Square;
  targets?: Square[];
}

export interface MoveEvent {
  from: Square;
  to: Square;
  piece: PieceChar;
}

export interface TapEvent {
  square: Square;
  piece: PieceChar | "";
}

export interface ShortcutOptions {
  /** "space": confirm with space bar (default). "auto": commit as soon as the rank digit is typed. */
  commitMode?: "space" | "auto";
  highlightColor?: string;
}

export interface ChessboardProps {
  fen: string;
  /** Board edge length in px. Default 400. */
  size?: number;
  /** "white" | "black". Booleans accepted for old-wrapper compat (true = black at bottom). */
  orientation?: "white" | "black" | boolean;
  lightColor?: string;
  darkColor?: string;
  /** Enable tap + drag interaction. Default false. */
  interactive?: boolean;
  /** Animate piece slides on fen change. Default true. */
  animated?: boolean;
  /** Default 200. */
  animationDurationMs?: number;
  moveHints?: MoveHints;
  arrows?: Arrow[];
  /** Show origin piece at 20% opacity while dragging. Default true. */
  ghostOnDrag?: boolean;
  /** Highlight the hovered square while dragging. */
  dropIndicator?: boolean | { color?: string };
  /** Opt-in keyboard square selection (a-h then 1-8, space to commit). */
  shortcuts?: boolean | ShortcutOptions;
  /** Rotate the top player's pieces 180°. Default false. */
  turnTopPlayerPieces?: boolean;
  /** Per-piece renderer overrides, merged over the bundled cburnett set. */
  pieces?: Partial<Record<PieceChar, PieceRenderer>>;
  /** Custom square renderer; replaces the default colored square. */
  renderSquare?: (info: SquareInfo) => JSX.Element;
  onMove?: (e: MoveEvent) => void;
  onTap?: (e: TapEvent) => void;
  onPieceTap?: (e: { square: Square; piece: PieceChar }) => void;
  onEmptyFieldTap?: (e: { square: Square }) => void;
  onPieceStartDrag?: (e: { square: Square; piece: PieceChar }) => void;
  onFenChanged?: (fen: string) => void;
}
