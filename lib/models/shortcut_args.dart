import 'package:flutter/material.dart';

typedef ShortcutHighlightBuilder = Widget Function(double size);

enum ShortcutCommitMode {
  /// User must press space to commit a fully narrowed (file + rank) selection.
  space,

  /// As soon as a rank narrows the selection to a single square, commit
  /// immediately without waiting for space.
  auto,
}

class ShortcutArgs {
  final ShortcutHighlightBuilder? highlightBuilder;
  final ShortcutCommitMode commitMode;

  const ShortcutArgs({
    this.highlightBuilder,
    this.commitMode = ShortcutCommitMode.space,
  });
}
