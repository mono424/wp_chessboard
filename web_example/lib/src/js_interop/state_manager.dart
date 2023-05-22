import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JSExport()
class StateManager {
  StateManager({
    required ValueNotifier<String> fen,
    required ValueNotifier<double> size,
    required ValueNotifier<String> lightColor,
    required ValueNotifier<String> darkColor,
  })  : _fen = fen, _size = size, _lightColor = lightColor, _darkColor = darkColor;

  final ValueNotifier<String> _fen;
  final ValueNotifier<double> _size;
  final ValueNotifier<String> _lightColor;
  final ValueNotifier<String> _darkColor;

  String getFen() {
    return _fen.value;
  }

  void setFen(String value) {
    _fen.value = value;
  }

  double getSize() {
    return _size.value;
  }

  void setSize(double value) {
    _size.value = value;
  }

  String getLightColor() {
    return _lightColor.value;
  }

  void setLightColor(String value) {
    _lightColor.value = value;
  }

  String getDarkColor() {
    return _darkColor.value;
  }

  void setDarkColor(String value) {
    _darkColor.value = value;
  }

  void onFenChanged(VoidCallback f) {
    _fen.addListener(f);
  }
}