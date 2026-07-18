import {
  For,
  Index,
  Show,
  createEffect,
  createMemo,
  createSignal,
  mergeProps,
  onMount,
  untrack,
} from "solid-js";
import type { Component, JSX } from "solid-js";
import { Arrows } from "./Arrows";
import { Hints } from "./Hints";
import { indexToXY, normalizeOrientation, pointToIndex } from "./coords";
import type { Orientation } from "./coords";
import { computeRenderList, indexToSquare, parseBoard } from "./fen";
import type { RenderPiece } from "./fen";
import { defaultPieceMap } from "./pieces";
import { createShortcuts } from "./shortcuts";
import type { ChessboardProps, PieceChar, SquareInfo } from "./types";

const DRAG_SLOP_PX = 6;
const SHORTCUT_FILL = "rgba(255, 213, 79, 0.4)"; // 0x66FFD54F
const DROP_INDICATOR_FILL = "rgba(0, 0, 0, 0.2)";

interface DragState {
  fromIndex: number;
  piece: PieceChar;
  x: number;
  y: number;
  hoverIndex: number | null;
}

interface PiecesState {
  fen: string;
  orientation: Orientation;
  squareSize: number;
  list: RenderPiece[];
}

export const Chessboard: Component<ChessboardProps> = (rawProps) => {
  const props = mergeProps(
    {
      size: 400,
      lightColor: "#EEEEEE", // grey.shade200
      darkColor: "#757575", // grey.shade600
      interactive: false,
      animated: true,
      animationDurationMs: 200,
      ghostOnDrag: false,
      turnTopPlayerPieces: false,
    },
    rawProps,
  );

  let root!: HTMLDivElement;

  const squareSize = () => props.size / 8;
  const orientation = () => normalizeOrientation(props.orientation);
  const board = createMemo(() => parseBoard(props.fen));
  const pieceMap = createMemo(() => ({ ...defaultPieceMap, ...props.pieces }));

  // Remount all pieces whenever fen/orientation/size changes (mirrors the
  // Flutter widget keying its layers by fen). Slide origins only apply on a
  // fen change — an orientation or size change repositions without animating.
  const piecesState = createMemo<PiecesState>((prev) => {
    const fen = props.fen;
    const o = orientation();
    const s = squareSize();
    const prevFen = prev === undefined || prev.fen === fen ? null : prev.fen;
    return { fen, orientation: o, squareSize: s, list: computeRenderList(prevFen, fen) };
  });

  const [drag, setDrag] = createSignal<DragState | null>(null);

  const activateSquare = (index: number) => {
    const square = indexToSquare(index);
    const piece = board()[index]!;
    props.onTap?.({ square, piece });
    if (piece === "") props.onEmptyFieldTap?.({ square });
    else props.onPieceTap?.({ square, piece });
  };

  const shortcutOpts = () => {
    const s = props.shortcuts;
    const base = typeof s === "object" && s !== null ? s : {};
    return { commitMode: "space" as const, ...base, enabled: !!s };
  };
  const shortcuts = createShortcuts(shortcutOpts, activateSquare);

  // Notify fen changes (skip the initial value) and abort any in-flight drag.
  createEffect<string>((prevFen) => {
    const fen = props.fen;
    if (prevFen !== undefined && prevFen !== fen) {
      setDrag(null);
      props.onFenChanged?.(fen);
    }
    return fen;
  });

  const boardPos = (e: PointerEvent) => {
    const rect = root.getBoundingClientRect();
    return { x: e.clientX - rect.left, y: e.clientY - rect.top };
  };
  const indexAt = (e: PointerEvent) => {
    const { x, y } = boardPos(e);
    return pointToIndex(x, y, props.size, orientation());
  };

  let down: { index: number; piece: PieceChar | ""; x: number; y: number } | null = null;

  const onPointerDown = (e: PointerEvent) => {
    if (shortcutOpts().enabled) {
      root.focus();
      shortcuts.clear();
    }
    if (!props.interactive || e.button !== 0) return;
    e.preventDefault();
    const index = indexAt(e);
    if (index === null) return;
    const { x, y } = boardPos(e);
    down = { index, piece: board()[index]!, x, y };
    root.setPointerCapture(e.pointerId);
  };

  const onPointerMove = (e: PointerEvent) => {
    if (down === null) return;
    const { x, y } = boardPos(e);
    const current = drag();
    if (current === null) {
      if (down.piece === "") return;
      if (Math.hypot(x - down.x, y - down.y) < DRAG_SLOP_PX) return;
      const piece = down.piece;
      props.onPieceStartDrag?.({ square: indexToSquare(down.index), piece });
      setDrag({
        fromIndex: down.index,
        piece,
        x,
        y,
        hoverIndex: pointToIndex(x, y, props.size, orientation()),
      });
    } else {
      setDrag({
        ...current,
        x,
        y,
        hoverIndex: pointToIndex(x, y, props.size, orientation()),
      });
    }
  };

  const onPointerUp = (e: PointerEvent) => {
    const current = drag();
    const started = down;
    down = null;
    setDrag(null);
    if (started === null) return;
    if (current !== null) {
      const to = indexAt(e);
      if (to !== null && to !== current.fromIndex) {
        props.onMove?.({
          from: indexToSquare(current.fromIndex),
          to: indexToSquare(to),
          piece: current.piece,
        });
      }
    } else {
      activateSquare(started.index);
    }
  };

  const onPointerCancel = () => {
    down = null;
    setDrag(null);
  };

  const squareInfos = createMemo<SquareInfo[]>(() => {
    const size = squareSize();
    return Array.from({ length: 64 }, (_, index) => ({
      index,
      file: index % 8,
      rank: Math.floor(index / 8),
      square: indexToSquare(index),
      size,
    }));
  });

  const isTopPlayerPiece = (piece: PieceChar) => {
    const isWhitePiece = piece === piece.toUpperCase();
    return orientation() === "white" ? !isWhitePiece : isWhitePiece;
  };

  const dropIndicatorColor = () => {
    const d = props.dropIndicator;
    return typeof d === "object" && d?.color ? d.color : DROP_INDICATOR_FILL;
  };

  const positioned = (
    index: number,
    extra?: JSX.CSSProperties,
  ): JSX.CSSProperties => {
    const { x, y } = indexToXY(index, squareSize(), orientation());
    return {
      position: "absolute",
      left: `${x}px`,
      top: `${y}px`,
      width: `${squareSize()}px`,
      height: `${squareSize()}px`,
      ...extra,
    };
  };

  return (
    <div
      ref={root}
      tabindex={shortcutOpts().enabled ? 0 : undefined}
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerCancel={onPointerCancel}
      onKeyDown={shortcuts.onKeyDown}
      style={{
        position: "relative",
        width: `${props.size}px`,
        height: `${props.size}px`,
        background: "black",
        "touch-action": "none",
        "user-select": "none",
        "-webkit-user-select": "none",
        outline: "none",
        overflow: "hidden",
      }}
    >
      {/* Squares */}
      <div style={{ position: "absolute", inset: "0" }}>
        <Index each={squareInfos()}>
          {(info) => (
            <div style={positioned(info().index)}>
              {props.renderSquare ? (
                props.renderSquare(info())
              ) : (
                <div
                  style={{
                    width: "100%",
                    height: "100%",
                    background:
                      (info().file + info().rank) % 2 === 1
                        ? props.lightColor
                        : props.darkColor,
                  }}
                />
              )}
            </div>
          )}
        </Index>
      </div>

      {/* Pieces */}
      <div style={{ position: "absolute", inset: "0" }}>
        <For each={piecesState().list}>
          {(p) => {
            const { orientation: o, squareSize: s } = untrack(piecesState);
            const animate = untrack(() => props.animated) && p.fromIndex !== null;
            const dest = indexToXY(p.index, s, o);
            const start = animate ? indexToXY(p.fromIndex!, s, o) : dest;
            let el!: HTMLDivElement;
            onMount(() => {
              if (!animate) return;
              el.getBoundingClientRect();
              el.style.transition = `transform ${props.animationDurationMs}ms ease-in-out`;
              el.style.transform = `translate(${dest.x}px, ${dest.y}px)`;
            });
            return (
              <div
                ref={el}
                style={{
                  position: "absolute",
                  left: "0",
                  top: "0",
                  width: `${s}px`,
                  height: `${s}px`,
                  transform: `translate(${start.x}px, ${start.y}px)`,
                  opacity:
                    drag()?.fromIndex === p.index
                      ? props.ghostOnDrag
                        ? "0.2"
                        : "0"
                      : "1",
                  rotate:
                    props.turnTopPlayerPieces && isTopPlayerPiece(p.piece)
                      ? "180deg"
                      : undefined,
                }}
              >
                {pieceMap()[p.piece](s)}
              </div>
            );
          }}
        </For>
      </div>

      {/* Hints */}
      <Hints
        hints={props.moveHints}
        squareSize={squareSize()}
        orientation={orientation()}
      />

      {/* Shortcut selection highlight */}
      <Show when={shortcutOpts().enabled && shortcuts.selection().file !== null}>
        <div style={{ position: "absolute", inset: "0", "pointer-events": "none" }}>
          <For
            each={
              shortcuts.selection().rank !== null
                ? [shortcuts.selection().rank! * 8 + shortcuts.selection().file!]
                : Array.from({ length: 8 }, (_, r) => r * 8 + shortcuts.selection().file!)
            }
          >
            {(index) => (
              <div
                style={positioned(index, {
                  background: shortcutOpts().highlightColor ?? SHORTCUT_FILL,
                })}
              />
            )}
          </For>
        </div>
      </Show>

      {/* Arrows */}
      <Arrows
        arrows={props.arrows}
        size={props.size}
        squareSize={squareSize()}
        orientation={orientation()}
      />

      {/* Drop indicator */}
      <Show
        when={
          props.dropIndicator && drag() !== null && drag()!.hoverIndex !== null
        }
      >
        <div
          style={positioned(drag()!.hoverIndex!, {
            background: dropIndicatorColor(),
            "border-radius": `${squareSize() * 0.15}px`,
            "pointer-events": "none",
          })}
        />
      </Show>

      {/* Floating dragged piece */}
      <Show when={drag()}>
        {(d) => (
          <div
            style={{
              position: "absolute",
              left: "0",
              top: "0",
              width: `${squareSize()}px`,
              height: `${squareSize()}px`,
              transform: `translate(${d().x - squareSize() / 2}px, ${d().y - squareSize() / 2}px)`,
              "pointer-events": "none",
              "z-index": "10",
            }}
          >
            {pieceMap()[d().piece](squareSize())}
          </div>
        )}
      </Show>
    </div>
  );
};

export default Chessboard;
