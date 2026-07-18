import { describe, expect, it } from "vitest";
import {
  computeRenderList,
  indexToSquare,
  parseBoard,
  squareToIndex,
} from "../src/fen";

const START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

function pieceAt(list: ReturnType<typeof computeRenderList>, square: string) {
  return list.find((p) => p.square === square);
}

describe("square helpers", () => {
  it("round-trips all 64 squares", () => {
    for (let i = 0; i < 64; i++) {
      expect(squareToIndex(indexToSquare(i))).toBe(i);
    }
    expect(squareToIndex("a1")).toBe(0);
    expect(squareToIndex("h1")).toBe(7);
    expect(squareToIndex("a8")).toBe(56);
    expect(squareToIndex("h8")).toBe(63);
  });
});

describe("parseBoard", () => {
  it("parses the starting position", () => {
    const b = parseBoard(START);
    expect(b[squareToIndex("a1")]).toBe("R");
    expect(b[squareToIndex("e1")]).toBe("K");
    expect(b[squareToIndex("e8")]).toBe("k");
    expect(b[squareToIndex("d8")]).toBe("q");
    expect(b[squareToIndex("e4")]).toBe("");
    expect(b.filter((p) => p !== "").length).toBe(32);
  });

  it("empty fen yields empty board", () => {
    expect(parseBoard("").every((p) => p === "")).toBe(true);
  });
});

describe("computeRenderList", () => {
  it("no previous fen → no animation origins", () => {
    const list = computeRenderList(null, START);
    expect(list.length).toBe(32);
    expect(list.every((p) => p.fromIndex === null)).toBe(true);
  });

  it("simple move: e2-e4 pawn animates from e2", () => {
    const after = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1";
    const list = computeRenderList(START, after);
    const pawn = pieceAt(list, "e4")!;
    expect(pawn.piece).toBe("P");
    expect(pawn.fromIndex).toBe(squareToIndex("e2"));
    // unmoved pieces have no origin
    expect(pieceAt(list, "a1")!.fromIndex).toBeNull();
  });

  it("capture: replaced piece animates from its origin", () => {
    const before = "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1";
    const after = "rnbqkbnr/ppp1pppp/8/3P4/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1";
    const list = computeRenderList(before, after);
    const pawn = pieceAt(list, "d5")!;
    expect(pawn.piece).toBe("P");
    expect(pawn.fromIndex).toBe(squareToIndex("e4"));
  });

  it("castling: king and rook both animate", () => {
    const before = "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1";
    const after = "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 1 1";
    const list = computeRenderList(before, after);
    expect(pieceAt(list, "g1")!.fromIndex).toBe(squareToIndex("e1"));
    expect(pieceAt(list, "f1")!.fromIndex).toBe(squareToIndex("h1"));
  });

  it("en passant: mover animates, captured pawn disappears", () => {
    const before = "rnbqkbnr/ppp1p1pp/8/3pPp2/8/8/PPPP1PPP/RNBQKBNR w KQkq f6 0 3";
    const after = "rnbqkbnr/ppp1p1pp/5P2/3p4/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 3";
    const list = computeRenderList(before, after);
    const pawn = pieceAt(list, "f6")!;
    expect(pawn.fromIndex).toBe(squareToIndex("e5"));
    expect(pieceAt(list, "f5")).toBeUndefined();
  });

  it("promotion: new piece pops in without origin", () => {
    const before = "8/P7/8/8/8/8/7k/K7 w - - 0 1";
    const after = "Q7/8/8/8/8/8/7k/K7 b - - 0 1";
    const list = computeRenderList(before, after);
    const queen = pieceAt(list, "a8")!;
    expect(queen.piece).toBe("Q");
    expect(queen.fromIndex).toBeNull();
  });

  it("keys are unique and change with fen", () => {
    const a = computeRenderList(null, START);
    const after = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1";
    const b = computeRenderList(START, after);
    expect(new Set(a.map((p) => p.key)).size).toBe(a.length);
    expect(a.find((p) => p.square === "a1")!.key).not.toBe(
      b.find((p) => p.square === "a1")!.key,
    );
  });
});
