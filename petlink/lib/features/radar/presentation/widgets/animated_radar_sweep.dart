import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pet_tokens.dart';

/// Radar animado con barrido giratorio (3.2s) y puntos que titilan según `Radar.dc.html`.
class AnimatedRadarSweep extends StatefulWidget {
  const AnimatedRadarSweep({
    super.key,
    this.size = 160,
  });

  final double size;

  @override
  State<AnimatedRadarSweep> createState() => _AnimatedRadarSweepState();
}

class _AnimatedRadarSweepState extends State<AnimatedRadarSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _RadarPainter(
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 160.0;
    canvas.save();
    canvas.scale(scale);

    const center = Offset(80, 80);

    // 1. Círculos concéntricos y retícula en #6A4A6A
    final gridPaint = Paint()
      ..color = const Color(0xFF6A4A6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, 74, gridPaint);
    canvas.drawCircle(center, 52, gridPaint);
    canvas.drawCircle(center, 28, gridPaint);

    // Cruz central
    canvas.drawLine(const Offset(80, 6), const Offset(80, 154), gridPaint);
    canvas.drawLine(const Offset(6, 80), const Offset(154, 80), gridPaint);

    // 2. Haz de barrido giratorio (sweep de 60 grados con degradado)
    final sweepAngleRad = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(80, 80);
    canvas.rotate(sweepAngleRad);
    canvas.translate(-80, -80);

    // Sector de barrido (arco de ~60 grados)
    final sweepPath = Path()
      ..moveTo(80, 80)
      ..lineTo(80, 6)
      ..arcToPoint(
        const Offset(144, 43), // ~60 grados a lo largo del círculo radio 74
        radius: const Radius.circular(74),
      )
      ..close();

    final sweepShader = SweepGradient(
      center: Alignment.center,
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (math.pi / 3),
      colors: [
        PetTokens.clay.withValues(alpha: 0.0),
        PetTokens.clay.withValues(alpha: 0.55),
      ],
    ).createShader(const Rect.fromLTWH(6, 6, 148, 148));

    canvas.drawPath(sweepPath, Paint()..shader = sweepShader);

    // Borde líder del radar
    canvas.drawLine(
      const Offset(80, 80),
      const Offset(80, 6),
      Paint()
        ..color = PetTokens.clayOnDark
        ..strokeWidth = 2,
    );
    canvas.restore();

    // 3. Puntos de detección (blips) con desvanecimiento cíclico
    // (112, 44), (128, 104), (50, 118), (40, 52)
    _drawBlip(canvas, const Offset(112, 44), 0.06, PetTokens.clayOnDark);
    _drawBlip(canvas, const Offset(128, 104), 0.31, PetTokens.clayOnDark);
    _drawBlip(canvas, const Offset(50, 118), 0.59, PetTokens.mintOnDark);
    _drawBlip(canvas, const Offset(40, 52), 0.81, PetTokens.clayOnDark);

    // 4. Punto central blanco
    canvas.drawCircle(center, 6, Paint()..color = PetTokens.cream);

    canvas.restore();
  }

  void _drawBlip(Canvas canvas, Offset pos, double phaseDelay, Color color) {
    final localT = (progress - phaseDelay) % 1.0;
    double opacity = 0.2;
    double scale = 1.0;

    if (localT < 0.10) {
      final p = localT / 0.10;
      opacity = p;
      scale = 0.3 + 1.0 * p;
    } else if (localT < 0.20) {
      final p = (localT - 0.10) / 0.10;
      opacity = 1.0;
      scale = 1.3 - 0.3 * p;
    } else if (localT < 0.80) {
      opacity = 1.0;
      scale = 1.0;
    } else {
      final p = (localT - 0.80) / 0.20;
      opacity = 1.0 - 0.8 * p;
      scale = 1.0;
    }

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    canvas.drawCircle(
      Offset.zero,
      5,
      Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

