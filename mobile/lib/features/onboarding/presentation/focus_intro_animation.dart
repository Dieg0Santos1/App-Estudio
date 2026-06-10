import 'dart:math' as math;

import 'package:flutter/material.dart';

class FocusIntroAnimation extends StatefulWidget {
  const FocusIntroAnimation({
    required this.step,
    required this.dimension,
    super.key,
  });

  final int step;
  final double dimension;

  @override
  State<FocusIntroAnimation> createState() => _FocusIntroAnimationState();
}

class _FocusIntroAnimationState extends State<FocusIntroAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FocusIntroPainter(
            step: widget.step,
            pulse: Curves.easeInOut.transform(_controller.value),
          ),
          size: Size.square(widget.dimension),
        );
      },
    );
  }
}

class _FocusIntroPainter extends CustomPainter {
  const _FocusIntroPainter({
    required this.step,
    required this.pulse,
  });

  final int step;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bookOpen = step == 0 ? 0.18 : 1.0;
    final bulbVisible = step == 0 ? 0.0 : 1.0;
    final bulbLit = step == 2 ? 1.0 : step == 1 ? 0.35 : 0.0;

    _drawHalo(canvas, center, size.shortestSide, bulbLit);
    _drawBook(canvas, center, size.shortestSide, bookOpen);
    if (bulbVisible > 0) {
      _drawBulb(canvas, center.translate(0, -32), size.shortestSide, bulbVisible, bulbLit);
    }
    _drawSparkles(canvas, center, size.shortestSide, bulbLit);
  }

  void _drawHalo(Canvas canvas, Offset center, double side, double bulbLit) {
    final radius = side * (0.34 + pulse * 0.03);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(const Color(0x0022D3EE), const Color(0xAA2DD4BF), bulbLit)!,
          const Color(0x0014B8A6),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, haloPaint);
  }

  void _drawBook(Canvas canvas, Offset center, double side, double open) {
    final spine = center.translate(0, side * 0.2);
    final leftAngle = -0.58 * open;
    final rightAngle = 0.58 * open;
    final pageWidth = side * 0.3;
    final pageHeight = side * 0.16;

    final shadowPaint = Paint()
      ..color = const Color(0xAA03152F)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: spine.translate(0, pageHeight * 0.48),
        width: side * 0.72,
        height: side * 0.16,
      ),
      shadowPaint,
    );

    _drawPage(
      canvas,
      spine,
      pageWidth,
      pageHeight,
      leftAngle,
      const Color(0xFF1B5E78),
      const Color(0xFF83EAF2),
      isLeft: true,
    );
    _drawPage(
      canvas,
      spine,
      pageWidth,
      pageHeight,
      rightAngle,
      const Color(0xFF123E62),
      const Color(0xFF2DD4BF),
      isLeft: false,
    );

    final spinePaint = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF2DD4BF);
    canvas.drawLine(spine.translate(0, -pageHeight * 0.75), spine.translate(0, 2), spinePaint);
  }

  void _drawPage(
    Canvas canvas,
    Offset spine,
    double width,
    double height,
    double angle,
    Color coverColor,
    Color lineColor, {
    required bool isLeft,
  }) {
    canvas.save();
    canvas.translate(spine.dx, spine.dy);
    canvas.rotate(angle);

    final sign = isLeft ? -1.0 : 1.0;
    final rect = Rect.fromLTWH(
      isLeft ? -width : 0,
      -height,
      width,
      height,
    );
    final radius = Radius.circular(height * 0.18);
    final pagePath = Path()..addRRect(RRect.fromRectAndRadius(rect, radius));

    final coverPaint = Paint()..color = coverColor;
    canvas.drawPath(pagePath, coverPaint);

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.48);
    canvas.drawPath(pagePath, edgePaint);

    final linePaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = lineColor.withValues(alpha: 0.65);
    for (var index = 0; index < 3; index++) {
      final y = -height * (0.7 - index * 0.22);
      canvas.drawLine(
        Offset(sign * width * 0.18, y),
        Offset(sign * width * 0.72, y),
        linePaint,
      );
    }

    canvas.restore();
  }

  void _drawBulb(Canvas canvas, Offset center, double side, double visible, double lit) {
    final yOffset = -side * 0.1 * (1 - visible) - pulse * 4;
    final bulbCenter = center.translate(0, yOffset);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(const Color(0x332DD4BF), const Color(0xCCFDE68A), lit)!,
          const Color(0x002DD4BF),
        ],
      ).createShader(Rect.fromCircle(center: bulbCenter, radius: side * 0.25));
    canvas.drawCircle(bulbCenter, side * (0.15 + lit * 0.05), glow);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(const Color(0xFF5EEAD4), const Color(0xFFFDE68A), lit)!
          .withValues(alpha: visible);
    final bulbPath = Path()
      ..addOval(Rect.fromCircle(center: bulbCenter, radius: side * 0.1))
      ..moveTo(bulbCenter.dx - side * 0.055, bulbCenter.dy + side * 0.105)
      ..lineTo(bulbCenter.dx + side * 0.055, bulbCenter.dy + side * 0.105)
      ..moveTo(bulbCenter.dx - side * 0.04, bulbCenter.dy + side * 0.135)
      ..lineTo(bulbCenter.dx + side * 0.04, bulbCenter.dy + side * 0.135);
    canvas.drawPath(bulbPath, outline);

    final rayPaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.18 + lit * 0.62);
    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index - math.pi / 2;
      final start = bulbCenter + Offset(math.cos(angle), math.sin(angle)) * side * 0.15;
      final end = bulbCenter + Offset(math.cos(angle), math.sin(angle)) * side * 0.21;
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, double side, double lit) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.24 + lit * 0.5);

    final points = [
      center.translate(-side * 0.34, -side * 0.16),
      center.translate(side * 0.32, -side * 0.2),
      center.translate(side * 0.25, side * 0.03),
    ];
    for (final point in points) {
      final length = side * (0.025 + pulse * 0.008);
      canvas.drawLine(point.translate(-length, 0), point.translate(length, 0), paint);
      canvas.drawLine(point.translate(0, -length), point.translate(0, length), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FocusIntroPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.pulse != pulse;
  }
}
