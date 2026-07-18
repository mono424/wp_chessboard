import { describe, expect, it } from "vitest";
import { indexToXY, normalizeOrientation, pointToIndex } from "../src/coords";
import { squareToIndex } from "../src/fen";

const SIZE = 400;
const SQ = SIZE / 8;

describe("indexToXY", () => {
  it("white orientation: a1 bottom-left, h8 top-right", () => {
    expect(indexToXY(squareToIndex("a1"), SQ, "white")).toEqual({ x: 0, y: 7 * SQ });
    expect(indexToXY(squareToIndex("h8"), SQ, "white")).toEqual({ x: 7 * SQ, y: 0 });
    expect(indexToXY(squareToIndex("e2"), SQ, "white")).toEqual({ x: 4 * SQ, y: 6 * SQ });
  });

  it("black orientation: a1 top-right", () => {
    expect(indexToXY(squareToIndex("a1"), SQ, "black")).toEqual({ x: 7 * SQ, y: 0 });
    expect(indexToXY(squareToIndex("h8"), SQ, "black")).toEqual({ x: 0, y: 7 * SQ });
  });
});

describe("pointToIndex", () => {
  it("is the inverse of indexToXY at square centers, both orientations", () => {
    for (const orientation of ["white", "black"] as const) {
      for (let i = 0; i < 64; i++) {
        const { x, y } = indexToXY(i, SQ, orientation);
        expect(pointToIndex(x + SQ / 2, y + SQ / 2, SIZE, orientation)).toBe(i);
      }
    }
  });

  it("returns null outside the board", () => {
    expect(pointToIndex(-1, 10, SIZE, "white")).toBeNull();
    expect(pointToIndex(10, -1, SIZE, "white")).toBeNull();
    expect(pointToIndex(SIZE, 10, SIZE, "white")).toBeNull();
    expect(pointToIndex(10, SIZE + 5, SIZE, "white")).toBeNull();
  });
});

describe("normalizeOrientation", () => {
  it("handles strings and legacy booleans", () => {
    expect(normalizeOrientation("white")).toBe("white");
    expect(normalizeOrientation("black")).toBe("black");
    expect(normalizeOrientation(undefined)).toBe("white");
    expect(normalizeOrientation(false)).toBe("white");
    expect(normalizeOrientation(true)).toBe("black");
  });
});
