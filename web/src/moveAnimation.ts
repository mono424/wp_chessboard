import type { PieceMoveAnimation } from "./types";

/**
 * Follow a custom move animation. When it finishes: `commit` (the board puts the
 * piece on its square) and then `cancel`, in that order and in one tick, so the
 * piece never shows on the wrong square between the two. Returns the cleanup for
 * a piece that unmounts first, which cancels instead and commits nothing.
 */
export function trackMoveAnimation(
  animation: PieceMoveAnimation,
  commit: () => void,
): () => void {
  let live = true;
  animation.finished.then(
    () => {
      if (!live) return;
      live = false;
      commit();
      animation.cancel();
    },
    () => {
      // Web Animations reject `finished` when cancelled. Nothing to do: whoever
      // cancelled it is already replacing this piece.
    },
  );
  return () => {
    if (!live) return;
    live = false;
    animation.cancel();
  };
}
