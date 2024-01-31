import 'package:flutter/material.dart';

class ShapeItem {
  Size size;
  ShapeItem? child;
  ShapeType shapeType;
  Offset startOffset;

  ShapeItem(
    this.size,
    this.child,
    this.startOffset, [
    this.shapeType = ShapeType.initial,
  ]);
}

enum ShapeType { eye, mouth, initial }
