import 'package:flutter/cupertino.dart';

import 'color_data.dart';

class DoughnutPaint extends CustomPainter {
  final Color color;
  DoughnutPaint({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final double outerRadius = size.width / 2; // 바깥 원 반지름
    final double innerRadius = outerRadius / 2; // 안쪽 원 반지름

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius; // 두께를 원의 차이로 설정

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (outerRadius + innerRadius) / 2, // 가운데 원의 중심 반지름
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 그림이 변경하지 않음
  }
}