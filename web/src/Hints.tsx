import { For, Show } from "solid-js";
import type { Component } from "solid-js";
import { indexToXY } from "./coords";
import type { Orientation } from "./coords";
import { squareToIndex } from "./fen";
import type { MoveHints } from "./types";

export const SELECTED_FILL = "rgba(244, 197, 66, 0.6)"; // 0x99F4C542
export const TARGET_FILL = "rgba(0, 0, 0, 0.4)"; // 0x66000000

export const Hints: Component<{
  hints: MoveHints | undefined;
  squareSize: number;
  orientation: Orientation;
}> = (props) => {
  const xy = (square: string) =>
    indexToXY(squareToIndex(square), props.squareSize, props.orientation);

  return (
    <div style={{ position: "absolute", inset: "0", "pointer-events": "none" }}>
      <Show when={props.hints?.selected}>
        {(selected) => (
          <div
            style={{
              position: "absolute",
              left: `${xy(selected()).x}px`,
              top: `${xy(selected()).y}px`,
              width: `${props.squareSize}px`,
              height: `${props.squareSize}px`,
              background: SELECTED_FILL,
            }}
          />
        )}
      </Show>
      <For each={props.hints?.targets ?? []}>
        {(target) => {
          const dot = props.squareSize * 0.2;
          const inset = (props.squareSize - dot) / 2;
          return (
            <div
              style={{
                position: "absolute",
                left: `${xy(target).x + inset}px`,
                top: `${xy(target).y + inset}px`,
                width: `${dot}px`,
                height: `${dot}px`,
                "border-radius": "50%",
                background: TARGET_FILL,
              }}
            />
          );
        }}
      </For>
    </div>
  );
};
