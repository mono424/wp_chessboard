class SquareLocation {
  final int rank;
  final int file;

  SquareLocation(this.rank, this.file);

  SquareLocation.fromString(String square) : 
    rank = square.codeUnitAt(1) - "1".codeUnitAt(0) + 1,
    file = square.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

  int get rankIndex {
    return rank - 1;
  }

  int get fileIndex {
    return file - 1;
  }
}