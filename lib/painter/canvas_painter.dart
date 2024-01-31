import 'package:flutter/material.dart';

import '../model/shader_model.dart';

class CanvasPainter extends CustomPainter {
  List<ShapeItem> shapes;
  final Color painterColor;
  final StrokeCap painterStrokeCap;
  final PaintingStyle paintingStyle;
  final double painterStrokeWidth;
  final ShapeType shapeType;
  final Radius borderRadius;

  CanvasPainter({
    required this.shapes,
    this.shapeType = ShapeType.initial,
    this.painterColor = Colors.white,
    this.painterStrokeCap = StrokeCap.round,
    this.paintingStyle = PaintingStyle.fill,
    this.painterStrokeWidth = 3,
    this.borderRadius = Radius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = painterColor
      ..strokeCap = painterStrokeCap
      ..style = paintingStyle
      ..strokeWidth = painterStrokeWidth;

    for (var shape in shapes) {
      final path = Path();

      path.moveTo(shape.startOffset.dx, shape.startOffset.dy);

      canvas.drawOval(
        Rect.fromLTWH(
          shape.startOffset.dx,
          shape.startOffset.dy,
          shape.size.width,
          shape.size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
