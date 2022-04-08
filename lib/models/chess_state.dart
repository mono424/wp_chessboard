enum StateEntryDelta {
  removed, none, added, replaced
}

class StateEntry {
  final String piece;
  final SquarePosition position;
  final ChessState state;

  StateEntry(this.piece, this.position, this.state);

  SquarePosition? lastPosition() {
    StateEntryDelta delta = state.getDelta(piece, state.last?.board[position.rank]?[position.file]?.piece ?? "");
    return delta == StateEntryDelta.added || delta == StateEntryDelta.replaced ? state.findFrom(piece) : null;
  }

  String getKey() {
    return "ste_" + position.toString() + "_" + piece;
  }
}

class SquarePosition {
  final int rank;
  final int file;

  SquarePosition(this.rank, this.file);

  @override
  String toString() {
    return rank.toString() + file.toString();
  }
}

class ChessState {
  static int zero = "0".codeUnitAt(0);
  static int nine = "9".codeUnitAt(0);
  static int space = " ".codeUnitAt(0);

  final ChessState? last;
  final String fen;
  late final Map<int, Map<int, StateEntry>> board;

  ChessState(this.fen, { this.last }) {
    Map<int, Map<int, StateEntry>> _board = {};

    if (fen == "") {
      for (var i = 0; i < 8; i++) {
        _board[i] = {};
        for (var j = 0; j < 8; j++) {
          _board[i]![j] = StateEntry("", SquarePosition(i, j), this);
        }
      }
    } else {
      int rank = 0;
      for (var fenRank in fen.split("/")) {
        int file = 0;
        int currRank = 7 - rank;
        _board[currRank] = {};

        for (var i = 0; i < fenRank.length; i++) {
          int piece = fenRank.codeUnitAt(i);
          if (piece == space) break;

          if (piece >= zero && piece <= nine) {
            for (int j = 0; j < piece-zero; j++) {
                _board[currRank]![file] = StateEntry("", SquarePosition(currRank, file), this);
                file++;
            }
          } else {
            String pieceNotation = String.fromCharCode(piece);
            _board[currRank]![file] = StateEntry(pieceNotation, SquarePosition(currRank, file), this);
            file++;
          }
        }
        rank++;
      }
    }

    board = _board;
  }

  StateEntryDelta getDelta(String piece, String lastPiece) {
    if (piece == lastPiece) return StateEntryDelta.none;
    if (lastPiece == "") return StateEntryDelta.added;
    if (piece == "") return StateEntryDelta.removed;
    return StateEntryDelta.replaced;
  }

  StateEntry getEntry(int rank, int file) {
    return board[rank-1]![file-1]!;
  }

  SquarePosition? findFrom(String piece) {
    if (last == null) {
      return null;
    }
    
    for (var rank in board.entries) {
      for (var file in rank.value.entries) {
        if (file.value.piece == "" && last!.board[rank.key]![file.key]!.piece == piece) {
          return SquarePosition(rank.key, file.key);
        }
      }
    }
    return null;
  }

}