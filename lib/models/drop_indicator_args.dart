import 'package:flutter/material.dart';

class DropIndicatorArgs {
  final double size;
  final Color color;
  final BorderRadius radius;

  DropIndicatorArgs({required this.size, required this.color, radius}) : radius = radius ?? BorderRadius.circular(size);
}