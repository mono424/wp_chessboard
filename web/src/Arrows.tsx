import { For, Show } from "solid-js";
import type { Component } from "solid-js";
import type { JSX } from "@solidjs/web";
import { indexToXY } from "./coords";
import type { Orientation } from "./coords";
import { squareToIndex } from "./fen";
import type { Arrow } from "./types";

export const DEFAULT_ARROW_COLOR = "#4CAF50"; // Flutter Colors.green
export const DEFAULT_ARROW_WIDTH = 4;
/** How much wider than the arrow itself the `outline` under-stroke is drawn. */
const OUTLINE_EXTRA = 3;
/** The head fades in over the last stretch of the shaft's draw-on. */
const HEAD_FADE = 0.45;

// The draw-on animation. The shaft's dasharray is set to its own length, so
// animating stroke-dashoffset to 0 walks the dash across it — no path
// measurement, and the browser interpolates a single number. Omitting `from`
// lets each shaft start at its own inline dashoffset, so one keyframe rule
// serves every arrow regardless of length.
//
// These live in a <style> inside the board's own <svg> because the package
// ships no stylesheet and should not require the host to import one.
const KEYFRAMES = `
@keyframes wp-arrow-draw { to { stroke-dashoffset: 0 } }
@keyframes wp-arrow-head { to { opacity: 1 } }
@media (prefers-reduced-motion: reduce) {
  .wp-arrow-shaft { animation: none; stroke-dashoffset: 0 }
  .wp-arrow-head { animation: none; opacity: 1 }
}
`;

interface Point {
  x: number;
  y: number;
}

// One arrow as three lines: the shaft, and the two barbs of the head. Drawn
// twice when the arrow has an outline — once fat and dark underneath, once in
// its own colour on top — so both passes stay in lockstep by construction.
const ArrowLines: Component<{
  from: Point;
  to: Point;
  head: [Point, Point];
  color: string;
  width: number;
  /** 0 = no animation. */
  durationMs: number;
  /** Shaft length in px, for the draw-on dash. */
  length: number;
}> = (props) => {
  const shaftStyle = (): JSX.CSSProperties | undefined =>
    props.durationMs > 0
      ? {
          "stroke-dasharray": `${props.length}`,
          "stroke-dashoffset": `${props.length}`,
          animation: `wp-arrow-draw ${props.durationMs}ms ease-out forwards`,
        }
      : undefined;
  const headStyle = (): JSX.CSSProperties | undefined =>
    props.durationMs > 0
      ? {
          opacity: "0",
          animation:
            `wp-arrow-head ${Math.round(props.durationMs * HEAD_FADE)}ms ease-out ` +
            `${Math.round(props.durationMs * (1 - HEAD_FADE))}ms forwards`,
        }
      : undefined;

  return (
    <g
      stroke={props.color}
      stroke-width={props.width}
      stroke-linecap="round"
      fill="none"
    >
      <line
        class="wp-arrow-shaft"
        x1={props.from.x}
        y1={props.from.y}
        x2={props.to.x}
        y2={props.to.y}
        style={shaftStyle()}
      />
      <line
        class="wp-arrow-head"
        x1={props.to.x}
        y1={props.to.y}
        x2={props.head[0].x}
        y2={props.head[0].y}
        style={headStyle()}
      />
      <line
        class="wp-arrow-head"
        x1={props.to.x}
        y1={props.to.y}
        x2={props.head[1].x}
        y2={props.head[1].y}
        style={headStyle()}
      />
    </g>
  );
};

export const Arrows: Component<{
  arrows: Arrow[] | undefined;
  size: number;
  squareSize: number;
  orientation: Orientation;
  /** Board-level default for an arrow that asks to animate. */
  animationDurationMs?: number;
}> = (props) => {
  const center = (square: string) => {
    const { x, y } = indexToXY(
      squareToIndex(square),
      props.squareSize,
      props.orientation,
    );
    return { x: x + props.squareSize / 2, y: y + props.squareSize / 2 };
  };

  return (
    <svg
      width={props.size}
      height={props.size}
      style={{ position: "absolute", inset: "0", "pointer-events": "none" }}
    >
      <style>{KEYFRAMES}</style>
      <For each={props.arrows ?? []}>
        {(arrow) => {
          const from = () => center(arrow.from);
          const to = () => center(arrow.to);
          const color = () => arrow.color ?? DEFAULT_ARROW_COLOR;
          const width = () => arrow.width ?? DEFAULT_ARROW_WIDTH;
          // The head grows a little with the stroke, or a thick arrow ends in a
          // stub: the barbs are as thick as the shaft, so at the fixed length
          // they merge into its tip instead of reading as an arrowhead. The
          // default width is a no-op here, leaving thin arrows exactly as before.
          const headLen = () =>
            props.squareSize * 0.24 + (width() - DEFAULT_ARROW_WIDTH) * 1.5;
          const angle = () =>
            Math.atan2(to().y - from().y, to().x - from().x);
          const head = (side: 1 | -1) => {
            const a = angle() + Math.PI + (side * Math.PI) / 6;
            return {
              x: to().x + headLen() * Math.cos(a),
              y: to().y + headLen() * Math.sin(a),
            };
          };
          const heads = (): [Point, Point] => [head(1), head(-1)];
          const length = () =>
            Math.hypot(to().x - from().x, to().y - from().y);
          const durationMs = () => {
            const a = arrow.animate;
            if (!a) return 0;
            return a === true ? (props.animationDurationMs ?? 200) : a;
          };
          return (
            <>
              <Show when={arrow.outline}>
                {(outline) => (
                  <ArrowLines
                    from={from()}
                    to={to()}
                    head={heads()}
                    color={outline()}
                    width={width() + OUTLINE_EXTRA}
                    durationMs={durationMs()}
                    length={length()}
                  />
                )}
              </Show>
              <ArrowLines
                from={from()}
                to={to()}
                head={heads()}
                color={color()}
                width={width()}
                durationMs={durationMs()}
                length={length()}
              />
            </>
          );
        }}
      </For>
    </svg>
  );
};
