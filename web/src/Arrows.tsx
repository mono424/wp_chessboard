import { For } from "solid-js";
import type { Component } from "solid-js";
import { indexToXY } from "./coords";
import type { Orientation } from "./coords";
import { squareToIndex } from "./fen";
import type { Arrow } from "./types";

export const DEFAULT_ARROW_COLOR = "#4CAF50"; // Flutter Colors.green

export const Arrows: Component<{
  arrows: Arrow[] | undefined;
  size: number;
  squareSize: number;
  orientation: Orientation;
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
      <For each={props.arrows ?? []}>
        {(arrow) => {
          const from = () => center(arrow.from);
          const to = () => center(arrow.to);
          const color = () => arrow.color ?? DEFAULT_ARROW_COLOR;
          const headLen = () => props.squareSize * 0.24;
          const angle = () =>
            Math.atan2(to().y - from().y, to().x - from().x);
          const head = (side: 1 | -1) => {
            const a = angle() + Math.PI + (side * Math.PI) / 6;
            return {
              x: to().x + headLen() * Math.cos(a),
              y: to().y + headLen() * Math.sin(a),
            };
          };
          return (
            <g
              stroke={color()}
              stroke-width="4"
              stroke-linecap="round"
              fill="none"
            >
              <line x1={from().x} y1={from().y} x2={to().x} y2={to().y} />
              <line x1={to().x} y1={to().y} x2={head(1).x} y2={head(1).y} />
              <line x1={to().x} y1={to().y} x2={head(-1).x} y2={head(-1).y} />
            </g>
          );
        }}
      </For>
    </svg>
  );
};
