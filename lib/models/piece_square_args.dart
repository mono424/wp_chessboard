import 'package:flutter/widgets.dart';
import 'package:wp_chessboard/models/square_info.dart';

/// What [SquarePieceBuilder] is asked to draw: one piece on one square.
class PieceSquareArgs {
  /// The square the piece stands on.
  final SquareInfo square;

  /// The board letter of the piece, "P" for a white pawn, "n" for a black knight.
  final String piece;

  /// The size of a square in logical pixels.
  final double size;

  /// The square the piece came from in this state change, or null when it did
  /// not move (or the board could not tell where it came from).
  final SquareInfo? from;

  /// Where [from] lies, seen from [square], in logical pixels in the piece's own
  /// upright frame: a widget translated by this offset stands on [from]. It
  /// already accounts for the board's orientation and for a top player's piece
  /// that is turned around. Null exactly when [from] is null.
  final Offset? fromOffset;

  /// Whether the board animates this state change (the `animation` flag of
  /// [WPChessboardController.setFen]).
  final bool animated;

  /// True when the board asks for what follows the finger while the piece is
  /// dragged. [from] is null then.
  final bool dragFeedback;

  const PieceSquareArgs({
    required this.square,
    required this.piece,
    required this.size,
    this.from,
    this.fromOffset,
    this.animated = false,
    this.dragFeedback = false,
  });

  /// Whether the piece arrived on [square] in this state change, with the
  /// board animating it.
  bool get moved => animated && from != null;
}

/// A piece drawn by [SquarePieceBuilder].
class SquarePiece {
  /// What to draw, sized to [PieceSquareArgs.size].
  final Widget child;

  /// The widget animates its own way from [PieceSquareArgs.fromOffset] to its
  /// square: the board places it on its square at once instead of sliding it,
  /// and draws it over the other pieces while it travels. Only has an effect
  /// when the piece moved ([PieceSquareArgs.moved]).
  final bool ownsTravel;

  const SquarePiece(this.child, {this.ownsTravel = false});
}

/// Draws the piece on a square, or returns null to draw the art of the
/// [PieceMap].
typedef SquarePieceBuilder = SquarePiece? Function(PieceSquareArgs args);
