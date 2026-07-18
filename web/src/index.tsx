export { Chessboard, Chessboard as WPChessboard, default } from "./Chessboard";
export { defaultPieceMap } from "./pieces";
export {
  BlackBishop,
  BlackKing,
  BlackKnight,
  BlackPawn,
  BlackQueen,
  BlackRook,
  WhiteBishop,
  WhiteKing,
  WhiteKnight,
  WhitePawn,
  WhiteQueen,
  WhiteRook,
} from "./pieces";
export {
  indexToSquare,
  parseBoard,
  squareToIndex,
} from "./fen";
export type {
  Arrow,
  ChessboardProps,
  MoveEvent,
  MoveHints,
  PieceChar,
  PieceRenderer,
  ShortcutOptions,
  Square,
  SquareInfo,
  TapEvent,
} from "./types";
