import 'package:flutter/material.dart';

typedef ShortcutHighlightBuilder = Widget Function(double size);

class ShortcutArgs {
  final ShortcutHighlightBuilder? highlightBuilder;

  const ShortcutArgs({this.highlightBuilder});
}
