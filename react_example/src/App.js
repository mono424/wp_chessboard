import React, { useState } from 'react';
import WPChessboard from './wp_chessboard/wp_chessboard';

const sampleGame = [
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1",
  "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1",
  "rnbqkbnr/ppp1pppp/8/3P4/8/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1",
  "rnb1kbnr/ppp1pppp/8/3q4/8/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1",
  "rnb1kbnr/ppp1pppp/8/3q4/8/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 1",
  "rnb1kbnr/ppp1pppp/8/q7/8/2N5/PPPP1PPP/R1BQKBNR w KQkq - 0 1",
  "rnb1kbnr/ppp1pppp/8/q7/3P4/2N5/PPP2PPP/R1BQKBNR w KQkq - 0 1",
  "rnb1kbnr/pp2pppp/2p5/q7/3P4/2N5/PPP2PPP/R1BQKBNR w KQkq - 0 1",
];

function App() {
  const [currentFen, setCurrentFen] = useState(sampleGame[0]);

  const didLoad = () => {
    console.log('WPChessboard loaded');
  }

  const play = async () => {
    for (const fen of sampleGame) {
      setCurrentFen(fen);
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
  
  return (
    <div className="App">
      <WPChessboard
        src="/flutter/main.dart.js"
        assetBase="/flutter/"
        didLoad={didLoad}
        size={600}
        fen={currentFen}
      />
      <button onClick={play}>Play</button>
    </div>
  );
}

export default App;
