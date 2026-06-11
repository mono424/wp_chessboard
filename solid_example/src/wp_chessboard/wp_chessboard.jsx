/* global _flutter */

import { onMount, onCleanup, createSignal, createEffect } from "solid-js";

/**
 * SolidJS wrapper around the Flutter `wp_chessboard` web build.
 *
 * It loads the compiled Flutter entrypoint into a host `<div>`, waits for the
 * `flutter-initialized` event to receive the Flutter `StateManager`, then keeps
 * the board in sync with the component props.
 *
 * Props:
 *  - src         {string}              URL of the Flutter entrypoint (e.g. "/flutter/main.dart.js")
 *  - assetBase   {string}              Base path for Flutter assets (e.g. "/flutter/")
 *  - size        {number}              Board size in pixels
 *  - fen         {string}              FEN string describing the position
 *  - orientation {boolean}             Board orientation (true/false flips the view)
 *  - lightColor  {string}              CSS color for the light squares
 *  - darkColor   {string}              CSS color for the dark squares
 *  - interactive {boolean}             When true, pieces can be dragged/clicked (raw pointer events)
 *  - moveHints   {{selected, targets}} Highlight a selected square + legal-move dots (targets: string[])
 *  - didLoad     {() => void}          Called once when the board has initialized
 *  - onFenChanged {(fen: string) => void} Called whenever the board's FEN changes
 *  - onMove      {({from, to}) => void} Called when the user drags a piece (interactive only)
 *  - onTap       {({square}) => void}  Called when the user clicks a square (interactive only)
 *
 * Note: do NOT destructure `props` — Solid relies on property access for
 * reactivity, so we read `props.x` inside effects.
 */
function WPChessboard(props) {
  let ref;
  const [state, setState] = createSignal(null);

  onMount(() => {
    if (!ref) return;

    _flutter.loader.loadEntrypoint({
      entrypointUrl: props.src,
      onEntrypointLoaded: async (engineInitializer) => {
        const appRunner = await engineInitializer.initializeEngine({
          hostElement: ref,
          assetBase: props.assetBase,
        });
        await appRunner.runApp();
      },
    });

    const onInitialized = (event) => {
      const manager = event.detail;
      props.didLoad?.();
      // The Flutter API has no remove-listener, so register exactly once here
      // and read the handler props lazily to always call the latest one.
      manager.onFenChanged(() => props.onFenChanged?.(manager.getFen()));
      // onMove is only present on interaction-capable builds; guard for safety.
      manager.onMove?.(() => {
        const raw = manager.getMove() || ""; // "<from><to>#<seq>"
        const mv = raw.split("#")[0];
        if (mv.length >= 4) props.onMove?.({ from: mv.slice(0, 2), to: mv.slice(2, 4) });
      });
      manager.onTap?.(() => {
        const raw = manager.getTap() || ""; // "<square>#<seq>"
        const sq = raw.split("#")[0];
        if (sq) props.onTap?.({ square: sq });
      });
      setState(manager);
    };

    ref.addEventListener("flutter-initialized", onInitialized, { once: true });
    onCleanup(() => ref?.removeEventListener("flutter-initialized", onInitialized));
  });

  // One effect per controllable prop. The Flutter setters are idempotent, so
  // re-running on prop changes is safe. Each effect tracks `state()` and the
  // prop it reads.
  createEffect(() => {
    const manager = state();
    if (!manager || props.size === undefined) return;
    manager.setSize(props.size);
  });

  createEffect(() => {
    const manager = state();
    if (!manager || props.fen === undefined) return;
    manager.setFen(props.fen);
  });

  createEffect(() => {
    const manager = state();
    if (!manager || props.orientation === undefined) return;
    manager.setOrientation(props.orientation);
  });

  createEffect(() => {
    const manager = state();
    if (!manager || props.lightColor === undefined) return;
    manager.setLightColor(props.lightColor);
  });

  createEffect(() => {
    const manager = state();
    if (!manager || props.darkColor === undefined) return;
    manager.setDarkColor(props.darkColor);
  });

  createEffect(() => {
    const manager = state();
    if (!manager || props.interactive === undefined) return;
    manager.setInteractive?.(props.interactive);
  });

  createEffect(() => {
    const manager = state();
    if (!manager) return;
    const h = props.moveHints || {};
    manager.setMoveHints?.(h.selected || "", (h.targets || []).join(","));
  });

  // Solid does not auto-append units, so the px suffix is explicit.
  return (
    <div
      ref={ref}
      style={{ width: `${props.size}px`, height: `${props.size}px` }}
    ></div>
  );
}

export default WPChessboard;
