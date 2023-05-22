/* global _flutter */

import React, { useRef, useEffect, useState } from 'react';

function WPChessboard({ src, assetBase, didLoad, size, fen }) {
  const ref = useRef(null);
  const [state, setState] = useState(null);

  useEffect(() => {
    if (!ref.current || state) return;
    _flutter.loader.loadEntrypoint({
      entrypointUrl: src,
      onEntrypointLoaded: async (engineInitializer) => {
        console.log(ref.current);
        let appRunner = await engineInitializer.initializeEngine({
          hostElement: ref.current,
          assetBase: assetBase,
        });
        await appRunner.runApp();
      }
    });

    ref.current.addEventListener("flutter-initialized", (event) => {
      let state = event.detail;
      didLoad();
      setState(state);
    }, {
      once: true,
    });
  }, [src, assetBase, didLoad, state]);

  useEffect(() => {
    if (!state) return;
    state.setSize(size);
  }, [size, state]);

  useEffect(() => {
    if (!state) return;
    state.setFen(fen);
  }, [fen, state]);


  return (
    <div style={{ width: size, height: size }} ref={ref}></div>
  );
}

export default WPChessboard;
