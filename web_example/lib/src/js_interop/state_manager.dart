import 'package:flutter/foundation.dart';
import 'package:js/js.dart';

@JSExport()
class StateManager {
  StateManager({
    required ValueNotifier<String> fen,
    required ValueNotifier<double> size,
    required ValueNotifier<String> lightColor,
    required ValueNotifier<String> darkColor,
    required ValueNotifier<bool> orientation,
    required ValueNotifier<bool> watermarkVisible,
    required ValueNotifier<double> watermarkOpacity,
  })  : _fen = fen, _size = size, _lightColor = lightColor, _darkColor = darkColor, _orientation = orientation, _watermarkVisible = watermarkVisible, _watermarkOpacity = watermarkOpacity;

  final ValueNotifier<String> _fen;
  final ValueNotifier<double> _size;
  final ValueNotifier<String> _lightColor;
  final ValueNotifier<String> _darkColor;
  final ValueNotifier<bool> _orientation;
  final ValueNotifier<bool> _watermarkVisible;
  final ValueNotifier<double> _watermarkOpacity;

  String getFen() {
    return _fen.value;
  }

  void setFen(String value) {
    _fen.value = value;
  }

  bool getOrientation() {
    return _orientation.value;
  }

  void setOrientation(bool value) {
    _orientation.value = value;
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

  bool getWatermarkVisible() {
    return _watermarkVisible.value;
  }

  void setWatermarkVisible(bool value) {
    _watermarkVisible.value = value;
  }

  double getWaterMarkOpacity() {
    return _watermarkOpacity.value;
  }

  void setWaterMarkOpacity(double value) {
    _watermarkOpacity.value = value;
  }

  void onFenChanged(VoidCallback f) {
    _fen.addListener(f);
  }
}