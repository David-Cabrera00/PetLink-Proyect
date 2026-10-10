import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative, low-contrast animal marks for branded backgrounds.
class AnimalPatternField extends StatefulWidget {
  const AnimalPatternField({super.key, required this.colors});

  final List<Color> colors;

  @override
  State<AnimalPatternField> createState() => _AnimalPatternFieldState();
}

class _AnimalPatternFieldState extends State<AnimalPatternField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _AnimalPatternPainter(
            progress: _controller.value,
            colors: widget.colors,
          ),
        ),
      ),
    );
  }
}

class _AnimalPatternPainter extends CustomPainter {
  const _AnimalPatternPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty || size.isEmpty) return;

    final shortestSide = math.min(size.width, size.height);
    final baseSize = (shortestSide * 0.055).clamp(10.0, 24.0).toDouble();

    for (var index = 0; index < 18; index++) {
      final column = index % 6;
      final row = index ~/ 6;
      final x = size.width * (0.08 + column * 0.17);
      final y = size.height * (0.12 + row * 0.34);
      final drift = math.sin((progress * math.pi * 2) + index) * 7;
      final opacity = 0.10 + (index % 3) * 0.025;
      final color = colors[index % colors.length].withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x + drift, y + math.cos(index * 1.7) * 8);
      canvas.rotate(math.sin(index * 2.3) * 0.35);
      _drawPaw(canvas, baseSize, color);
      canvas.restore();
    }
  }

  void _drawPaw(Canvas canvas, double size, Color color) {
    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size * 0.95,
        height: size * 0.72,
      ),
      paint,
    );

    final toeRadius = size * 0.19;
    final toeOffset = size * 0.38;
    for (var index = 0; index < 3; index++) {
      final angle = -0.95 + index * 0.95;
      canvas.drawCircle(
        Offset(math.cos(angle) * toeOffset, math.sin(angle) * toeOffset),
        toeRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimalPatternPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
