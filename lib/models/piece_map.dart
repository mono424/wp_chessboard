import 'package:flutter/material.dart';

typedef PieceBuilder = Widget Function(double size);

class PieceMap {
  final PieceBuilder K;
  final PieceBuilder Q;
  final PieceBuilder B;
  final PieceBuilder N;
  final PieceBuilder R;
  final PieceBuilder P;

  final PieceBuilder k;
  final PieceBuilder q;
  final PieceBuilder b;
  final PieceBuilder n;
  final PieceBuilder r;
  final PieceBuilder p;

  PieceMap({required this.K, required this.Q, required this.B, required this.N, required this.R, required this.P, required this.k, required this.q, required this.b, required this.n, required this.r, required this.p});

  PieceBuilder get(String notation) {
    switch (notation) {
      case 'K':
        return K;
      case 'Q':
        return Q;
      case 'B':
        return B;
      case 'N':
        return N;
      case 'R':
        return R;
      case 'P':
        return P;
      case 'k':
        return k;
      case 'q':
        return q;
      case 'b':
        return b;
      case 'n':
        return n;
      case 'r':
        return r;
      case 'p':
        return p;
      default:
        throw Exception("Invalid piece notation: '" + notation + "'.");
    }
  }
}