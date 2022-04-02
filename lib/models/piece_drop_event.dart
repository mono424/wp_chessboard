import 'package:wp_chessboard/models/square_info.dart';

class PieceDropEvent {
  final SquareInfo from;
  final SquareInfo to;

  PieceDropEvent(this.from, this.to);
}