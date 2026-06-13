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
    required ValueNotifier<bool> interactive,
    required ValueNotifier<String> move,
    required ValueNotifier<String> tap,
    required ValueNotifier<String> hints,
    required ValueNotifier<String> arrows,
    required ValueNotifier<bool> animate,
  })  : _fen = fen, _size = size, _lightColor = lightColor, _darkColor = darkColor, _orientation = orientation, _interactive = interactive, _move = move, _tap = tap, _hints = hints, _arrows = arrows, _animate = animate;

  final ValueNotifier<String> _fen;
  final ValueNotifier<double> _size;
  final ValueNotifier<String> _lightColor;
  final ValueNotifier<String> _darkColor;
  final ValueNotifier<bool> _orientation;
  final ValueNotifier<bool> _interactive;
  final ValueNotifier<String> _move;
  final ValueNotifier<String> _tap;
  final ValueNotifier<String> _hints;
  final ValueNotifier<String> _arrows;
  final ValueNotifier<bool> _animate;

  // When false, setFen snaps pieces to the new position instead of sliding them
  // (a 200ms AnimatedPositioned per move). Display-only/analysis hosts disable
  // this: each animated move repaints over several frames, so stepping through a
  // game storms the main thread and freezes the page on mobile. Defaults to true.
  bool getAnimated() {
    return _animate.value;
  }

  void setAnimated(bool value) {
    _animate.value = value;
  }

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

  void onFenChanged(VoidCallback f) {
    _fen.addListener(f);
  }

  // When true, pieces can be dragged (the board reports drops via [getMove] /
  // [onMove]). When false the board is display-only. Defaults to false.
  bool getInteractive() {
    return _interactive.value;
  }

  void setInteractive(bool value) {
    _interactive.value = value;
  }

  // The last user drag, encoded as "<from><to>#<seq>" (e.g. "e2e4#3"). The
  // trailing nonce guarantees the notifier fires even when the same squares are
  // dragged twice in a row; JS strips it. Empty until the first drag.
  String getMove() {
    return _move.value;
  }

  void onMove(VoidCallback f) {
    _move.addListener(f);
  }

  // A single tap on a square, encoded as "<square>#<seq>" (e.g. "e2#3"). JS uses
  // this to drive click-to-move + selection (it owns the chess logic).
  String getTap() {
    return _tap.value;
  }

  void onTap(VoidCallback f) {
    _tap.addListener(f);
  }

  // Called by JS to highlight the current selection + its legal targets. [selected]
  // is a square (or "") and [targets] is a comma-separated list of squares. The
  // board renders the selected square as a fill and each target as a move dot.
  void setMoveHints(String selected, String targets) {
    _hints.value = '$selected|$targets';
  }

  // Called by JS to draw arrows on the board (e.g. engine candidate moves). The
  // value is a comma-separated list of "<from><to>[:<AARRGGBB>]" entries — from
  // and to are squares (a1..h8) and the optional 8-digit hex is an ARGB color.
  // e.g. "e2e4:ff5e6ad2,d2d4:805e6ad2". Empty string clears all arrows.
  void setArrows(String value) {
    _arrows.value = value;
  }
}