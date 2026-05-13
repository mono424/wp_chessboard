library wp_chessboard;

import 'package:flutter/material.dart';

class ShortcutHighlight extends StatelessWidget {
  final double size;
  final Color color;

  const ShortcutHighlight({Key? key, required this.size, this.color = const Color(0x66FFD54F)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        color: color,
      ),
    );
  }
}
