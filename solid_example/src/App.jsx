import { createSignal } from "solid-js";
import { Chess } from "chess.js";
import { WPChessboard } from "wp-chessboard-solid";

const START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

const sampleGame = [
  START_FEN,
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
  const [currentFen, setCurrentFen] = createSignal(START_FEN);
  const [orientation, setOrientation] = createSignal("white");
  const [interactive, setInteractive] = createSignal(true);
  const [hints, setHints] = createSignal(null);
  const [lastMove, setLastMove] = createSignal(null);

  const game = () => new Chess(currentFen());

  const applyMove = (from, to) => {
    const g = game();
    try {
      const move = g.move({ from, to, promotion: "q" });
      setCurrentFen(g.fen());
      setLastMove({ from: move.from, to: move.to });
      setHints(null);
      return true;
    } catch {
      return false;
    }
  };

  const selectSquare = (square) => {
    const targets = game()
      .moves({ square, verbose: true })
      .map((m) => m.to);
    setHints(targets.length > 0 ? { selected: square, targets } : null);
  };

  const onTap = ({ square }) => {
    const current = hints();
    if (current && current.targets.includes(square)) {
      applyMove(current.selected, square);
    } else if (current && current.selected === square) {
      setHints(null);
    } else {
      selectSquare(square);
    }
  };

  const onMove = ({ from, to }) => {
    applyMove(from, to);
  };

  const play = async () => {
    setHints(null);
    setLastMove(null);
    for (const fen of sampleGame) {
      setCurrentFen(fen);
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  };

  const reset = () => {
    setCurrentFen(START_FEN);
    setHints(null);
    setLastMove(null);
  };

  return (
    <div class="App">
      <WPChessboard
        size={600}
        fen={currentFen()}
        orientation={orientation()}
        lightColor="#f0d9b5"
        darkColor="#b58863"
        interactive={interactive()}
        moveHints={hints()}
        arrows={lastMove() ? [lastMove()] : []}
        dropIndicator
        shortcuts
        onTap={onTap}
        onMove={onMove}
        onFenChanged={(fen) => console.log("FEN changed:", fen)}
      />
      <div>
        <button onClick={play}>Play</button>
        <button onClick={reset}>Reset</button>
        <button
          onClick={() =>
            setOrientation((o) => (o === "white" ? "black" : "white"))
          }
        >
          Flip board
        </button>
        <button onClick={() => setInteractive((i) => !i)}>
          {interactive() ? "Disable" : "Enable"} interaction
        </button>
      </div>
    </div>
  );
}

export default App;
