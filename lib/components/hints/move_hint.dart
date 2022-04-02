library wp_chessboard;

import 'package:flutter/material.dart';

class MoveHint extends StatelessWidget {
  final double size;
  final Color color;
  final VoidCallback? onPressed;

  const MoveHint({Key? key, required this.size, this.color = Colors.tealAccent, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double hintSize = size * 0.2;

    return GestureDetector(
      onTapDown: onPressed != null ? (_) => onPressed!() : null,
      child: Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: hintSize,
              height: hintSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(hintSize)
              ),
            )
          ],
        ),
      )
    );
  }

}