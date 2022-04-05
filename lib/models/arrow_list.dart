import 'package:wp_chessboard/models/arrow.dart';

class ArrowList {
  static int _lastId = 0;
  late int _id;
  
  final List<Arrow> value;

  int get id {
    return _id;
  }

  ArrowList(this.value) {
    _updateId();
  }

  void _updateId() {
    _id = _lastId++;
  }

}