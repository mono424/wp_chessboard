class ChessState {
  static int zero = "0".codeUnitAt(0);
  static int nine = "9".codeUnitAt(0);

  final String fen;
  late final Map<int, Map<int, String>> board;

  ChessState(this.fen) {
    Map<int, Map<int, String>> _board = {};

    if (fen == "") {
      for (var i = 0; i < 8; i++) {
        _board[i] = {};
        for (var j = 0; j < 8; j++) {
          _board[i]![j] = "";
        }
      }
    } else {
      int rank = 0;
      for (var fenRank in fen.split("/")) {
        int file = 0;
        _board[7 - rank] = {};

        for (var i = 0; i < fenRank.length; i++) {
          int piece = fenRank.codeUnitAt(i);
          if (piece >= zero && piece <= nine) {
            for (int j = 0; j < piece-zero; j++) {
                _board[7 - rank]![file] = "";
                file++;
            }
          } else {
            _board[7 - rank]![file] = String.fromCharCode(piece);
            file++;
          }
        }
        rank++;
      }
    }

    board = _board;
  }

  String getPiece(int rank, int file) {
    return board[rank-1]![file-1]!;
  } 

}