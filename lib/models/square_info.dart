class SquareInfo {
  final int index;
  final int file;
  final int rank;
  final double size;

  SquareInfo(this.index, this.size) : file = ((index % 8) + 1), rank = ((index / 8).floor() + 1);

  @override
  String toString() {
    return String.fromCharCode("a".codeUnitAt(0) + (file - 1)) + rank.toString();
  }
}