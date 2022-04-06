import 'package:flutter/material.dart';

typedef HintBuilder = Widget Function(double size);

class HintMap {
  static int _lastId = 0;
  final String key;
  late int _id;
  Map<int, Map<int, HintBuilder?>> board = {};

  int get id {
    return _id;
  }

  HintMap({ this.key = "" }) {
    _updateId();
    for (var i = 0; i < 8; i++) {
      board[i] = {};
      for (var j = 0; j < 8; j++) {
        board[i]![j] = null;
      }
    }
  }

  void _updateId() {
    _id = _lastId++;
  }

  HintMap set(int rank, int file, HintBuilder? widget) {
    board[rank-1]![file-1] = widget;
    return this;
  }

  HintBuilder? getHint(int rank, int file) {
     return board[rank-1]![file-1];
  }
  
}