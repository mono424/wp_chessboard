import type { JSX } from "@solidjs/web";

export type PieceChar =
  | "K" | "Q" | "R" | "B" | "N" | "P"
  | "k" | "q" | "r" | "b" | "n" | "p";

/** Algebraic square name, "a1".."h8". */
export type Square = string;

export type PieceRenderer = (size: number) => JSX.Element;

/** What `renderPiece` is being asked to draw. */
export interface PieceRenderInfo {
  piece: PieceChar;
  /** The square it stands on. While dragging, the square it was lifted from. */
  square: Square;
  size: number;
}

/** A piece that just changed squares, handed to `animateMove`. */
export interface PieceMoveInfo {
  piece: PieceChar;
  from: Square;
  to: Square;
  size: number;
  /** Signed travel on screen in px, from `from` to `to`. Follows the orientation. */
  dx: number;
  dy: number;
  /** The piece's element, holding what the renderer drew. It stays on `from` until `finished`. */
  el: HTMLElement;
}

/** A running custom move animation. */
export interface PieceMoveAnimation {
  /** When it resolves the board puts the piece on `to`, then calls `cancel`. */
  finished: Promise<unknown>;
  /** Drop whatever the animation left behind. Also called if the piece unmounts first. */
  cancel: () => void;
}

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
  /** Stroke width in px. Default 4. */
  width?: number;
  /**
   * When set, an under-stroke of this colour is drawn first, `width + 3` thick,
   * giving the arrow a dark edge so it stays legible over either square colour.
   */
  outline?: string;
  /**
   * 0..1, applied to the arrow as a whole (shaft, head and outline together),
   * so a faded arrow has an even tint. Default 1.
   */
  opacity?: number;
  /**
   * Draw the arrow on rather than popping it in: the shaft extends from origin
   * to destination and the head fades in as it lands. `true` uses the board's
   * `animationDurationMs`; a number overrides it. Leave unset for arrows that
   * update often (engine candidate lines), which would otherwise strobe.
   */
  animate?: boolean | number;
}

/**
 * A marked square: a tint under the pieces, and/or a badge on top of
 * everything. Use it to say something about a square itself (which move was
 * just played, and what the analysis thinks of it) rather than about a path,
 * which is what `Arrow` is for.
 */
export interface SquareMark {
  square: Square;
  /** Square tint, drawn UNDER the pieces. Any CSS colour. */
  fill?: string;
  /** Inset border drawn with the fill, for a square that needs more emphasis. */
  ring?: string;
  /** Corner glyph drawn OVER the pieces and arrows. */
  badge?: {
    text: string;
    /** Glyph colour. */
    color: string;
    /** Badge disc colour. */
    background: string;
  };
  /** Animate the mark in. `true` uses the board's `animationDurationMs`. */
  animate?: boolean | number;
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
  /** Marked squares: tints under the pieces, badges over everything. */
  marks?: SquareMark[];
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
  /**
   * Per-piece renderer that knows the square, for art that belongs to one
   * particular piece rather than to a kind of piece. Return nothing to fall back
   * to `pieces`.
   */
  renderPiece?: (info: PieceRenderInfo) => JSX.Element | null | undefined;
  /**
   * Replace the slide of one moving piece. Runs after the piece is mounted on
   * `from`, only where the slide would have played (so never with `animated`
   * off). Return nothing to keep the plain slide. The position is already the
   * new one: this is only how the piece gets there, and the next `fen` cuts it.
   */
  animateMove?: (info: PieceMoveInfo) => PieceMoveAnimation | null | undefined;
  /** Custom square renderer; replaces the default colored square. */
  renderSquare?: (info: SquareInfo) => JSX.Element;
  onMove?: (e: MoveEvent) => void;
  onTap?: (e: TapEvent) => void;
  onPieceTap?: (e: { square: Square; piece: PieceChar }) => void;
  onEmptyFieldTap?: (e: { square: Square }) => void;
  onPieceStartDrag?: (e: { square: Square; piece: PieceChar }) => void;
  onFenChanged?: (fen: string) => void;
}
