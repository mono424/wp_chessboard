import { For, Show } from "solid-js";
import type { Component } from "solid-js";
import type { JSX } from "@solidjs/web";
import { indexToXY } from "./coords";
import type { Orientation } from "./coords";
import { squareToIndex } from "./fen";
import type { SquareMark } from "./types";

// Square marks come in two layers that must sit at different depths:
//
//   "fill"  the square tint, UNDER the pieces, so a highlighted square reads as
//           coloured board rather than a sheet laid over the piece on it.
//   "badge" the corner glyph, OVER everything including the arrows, since its
//           whole job is to be read.
//
// Both render from the same `marks` array; Chessboard mounts this component
// twice, once per layer.
export type MarkLayer = "fill" | "badge";

// The tint just resolves in; the badge overshoots slightly on the way, which is
// what stops a small glyph appearing out of nowhere and reads as it being
// stamped onto the square.
const KEYFRAMES = `
@keyframes wp-mark-in { from { opacity: 0; transform: scale(0.82) } to { opacity: 1; transform: none } }
@keyframes wp-badge-in {
  0%   { opacity: 0; transform: scale(0.2) }
  62%  { opacity: 1; transform: scale(1.14) }
  100% { opacity: 1; transform: none }
}
@media (prefers-reduced-motion: reduce) {
  .wp-mark, .wp-badge { animation: none !important; opacity: 1; transform: none }
}
`;

export const Marks: Component<{
  marks: SquareMark[] | undefined;
  layer: MarkLayer;
  squareSize: number;
  orientation: Orientation;
  /** Board-level default for a mark that asks to animate. */
  animationDurationMs?: number;
}> = (props) => {
  const xy = (square: string) =>
    indexToXY(squareToIndex(square), props.squareSize, props.orientation);

  // `both` so the element holds the keyframe's opening frame before it starts:
  // without it a delayed badge flashes at full size for one frame.
  const anim = (
    mark: SquareMark,
    name: string,
    ms: number,
    delayFraction = 0,
  ): JSX.CSSProperties => {
    const a = mark.animate;
    const base = a === true ? (props.animationDurationMs ?? 200) : a || 0;
    if (!base) return {};
    const delay = Math.round(base * delayFraction);
    return {
      animation: `${name} ${ms}ms cubic-bezier(0.2, 0.9, 0.3, 1.2) ${delay}ms both`,
    };
  };

  const Fill: Component<{ mark: SquareMark }> = (p) => (
    <Show when={p.mark.fill}>
      {(fill) => (
        <div
          class="wp-mark"
          style={{
            position: "absolute",
            left: `${xy(p.mark.square).x}px`,
            top: `${xy(p.mark.square).y}px`,
            width: `${props.squareSize}px`,
            height: `${props.squareSize}px`,
            background: fill(),
            ...(p.mark.ring
              ? {
                  "box-shadow": `inset 0 0 0 ${Math.max(2, props.squareSize * 0.045)}px ${p.mark.ring}`,
                }
              : {}),
            ...anim(p.mark, "wp-mark-in", 190),
          }}
        />
      )}
    </Show>
  );

  const Badge: Component<{ mark: SquareMark }> = (p) => (
    <Show when={p.mark.badge}>
      {(badge) => {
        // Sized off the square so the badge holds its proportions at any board
        // size. A one-character glyph ("!", "?") gets a larger face than a
        // two-character one ("?!", "??"), which otherwise has to be set small
        // enough to fit and leaves the short glyphs looking lost in the disc.
        const d = () => props.squareSize * 0.44;
        const fontRatio = () => ((badge().text?.length ?? 1) > 1 ? 0.46 : 0.6);
        return (
          <div
            class="wp-badge"
            style={{
              position: "absolute",
              // Top-right, pulled slightly outside the square so it straddles
              // the edge instead of covering the piece.
              left: `${xy(p.mark.square).x + props.squareSize - d() * 0.62}px`,
              top: `${xy(p.mark.square).y - d() * 0.22}px`,
              width: `${d()}px`,
              height: `${d()}px`,
              "border-radius": "50%",
              background: badge().background,
              color: badge().color,
              display: "flex",
              "align-items": "center",
              "justify-content": "center",
              "font-family":
                "ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif",
              "font-size": `${d() * fontRatio()}px`,
              "font-weight": "700",
              "line-height": "1",
              "letter-spacing": "-0.04em",
              "box-shadow": "0 1px 3px rgba(0, 0, 0, 0.45)",
              // Lands after the tint, so the eye goes to the square first and
              // the verdict second.
              ...anim(p.mark, "wp-badge-in", 260, 0.35),
            }}
          >
            {badge().text}
          </div>
        );
      }}
    </Show>
  );

  return (
    <div style={{ position: "absolute", inset: "0", "pointer-events": "none" }}>
      <style>{KEYFRAMES}</style>
      <For each={props.marks ?? []}>
        {(mark) =>
          props.layer === "fill" ? <Fill mark={mark} /> : <Badge mark={mark} />
        }
      </For>
    </div>
  );
};
