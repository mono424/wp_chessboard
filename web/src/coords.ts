export type Orientation = "white" | "black";

/** Top-left pixel position of a board index for the given orientation. */
export function indexToXY(
  index: number,
  squareSize: number,
  orientation: Orientation,
): { x: number; y: number } {
  const file = index % 8;
  const rank = Math.floor(index / 8);
  if (orientation === "white") {
    return { x: file * squareSize, y: (7 - rank) * squareSize };
  }
  return { x: (7 - file) * squareSize, y: rank * squareSize };
}

/** Board index under a pixel point, or null when outside the board. */
export function pointToIndex(
  x: number,
  y: number,
  size: number,
  orientation: Orientation,
): number | null {
  if (x < 0 || y < 0 || x >= size || y >= size) return null;
  const squareSize = size / 8;
  let file = Math.floor(x / squareSize);
  let rank = 7 - Math.floor(y / squareSize);
  if (orientation === "black") {
    file = 7 - file;
    rank = 7 - rank;
  }
  if (file < 0 || file > 7 || rank < 0 || rank > 7) return null;
  return rank * 8 + file;
}

export function normalizeOrientation(
  o: "white" | "black" | boolean | undefined,
): Orientation {
  if (o === true || o === "black") return "black";
  return "white";
}
