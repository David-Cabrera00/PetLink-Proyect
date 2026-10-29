import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/pet_tokens.dart';

/// Mascota reactiva oficial de PetLink para Login y Registro.
///
/// Estados interactivos según el diseño:
/// - En reposo: parpadeo suave y balanceo de orejas (o ladeo de cabeza).
/// - Foco en correo: las pupilas se desplazan hacia el input (-3, +3).
/// - Foco en contraseña: las patas suben con rebote y se cubren los ojos.
/// - Contraseña visible (peeking): una pata baja para espiar con un ojo.
class ReactivePetAvatar extends StatefulWidget {
  const ReactivePetAvatar({
    super.key,
    this.size = 150,
    this.lookAtEmail = false,
    this.coverEyes = false,
    this.peeking = false,
    this.tiltHead = false,
  });

  final double size;
  final bool lookAtEmail;
  final bool coverEyes;
  final bool peeking;
  final bool tiltHead;

  @override
  State<ReactivePetAvatar> createState() => _ReactivePetAvatarState();
}

class _ReactivePetAvatarState extends State<ReactivePetAvatar>
    with TickerProviderStateMixin {
  // Animación continua de parpadeo y balanceo en reposo
  late final AnimationController _idleController;
  // Animación elástica de las patas
  late final AnimationController _pawsController;

  @override
  void initState() {
    super.initState();

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _pawsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    if (widget.coverEyes) {
      _pawsController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ReactivePetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coverEyes != oldWidget.coverEyes) {
      if (widget.coverEyes) {
        _pawsController.forward();
      } else {
        _pawsController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _pawsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.size / 150.0;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _pawsController]),
        builder: (context, _) {
          final t = _idleController.value;

          // Parpadeo: ocurre entre el 95% y el 99% del ciclo de 5s
          double blinkScaleY = 1.0;
          if (t >= 0.95 && t <= 0.97) {
            blinkScaleY = 1.0 - ((t - 0.95) / 0.02) * 0.88;
          } else if (t > 0.97 && t <= 0.99) {
            blinkScaleY = 0.12 + ((t - 0.97) / 0.02) * 0.88;
          }

          // Balanceo de oreja izquierda y derecha
          final earCycle = (t * 5 / 4) % 1.0; // ciclo de 4s
          double earLeftAngle = 0.0;
          if (earCycle >= 0.90 && earCycle <= 0.94) {
            earLeftAngle = ((earCycle - 0.90) / 0.04) * (8 * math.pi / 180);
          } else if (earCycle > 0.94 && earCycle <= 0.98) {
            earLeftAngle = (1.0 - (earCycle - 0.94) / 0.04) * (8 * math.pi / 180);
          }

          final earRightCycle = ((t * 5 + 0.3) / 4) % 1.0;
          double earRightAngle = 0.0;
          if (earRightCycle >= 0.90 && earRightCycle <= 0.94) {
            earRightAngle =
                ((earRightCycle - 0.90) / 0.04) * (8 * math.pi / 180);
          } else if (earRightCycle > 0.94 && earRightCycle <= 0.98) {
            earRightAngle =
                (1.0 - (earRightCycle - 0.94) / 0.04) * (8 * math.pi / 180);
          }

          // Ladeo de cabeza para pantalla de Registro (-9° entre 70% y 85% de 3.6s)
          double headTilt = 0.0;
          if (widget.tiltHead) {
            final headCycle = (t * 5 / 3.6) % 1.0;
            if (headCycle >= 0.60 && headCycle <= 0.70) {
              headTilt = -((headCycle - 0.60) / 0.10) * (9 * math.pi / 180);
            } else if (headCycle > 0.70 && headCycle <= 0.85) {
              headTilt = -(9 * math.pi / 180);
            } else if (headCycle > 0.85 && headCycle <= 0.95) {
              headTilt = -(1.0 - (headCycle - 0.85) / 0.10) * (9 * math.pi / 180);
            }
          }

          // Curva de rebote elástica para subir las patitas
          final pawProgress = PetTokens.bounce.transform(_pawsController.value);
          // translateY: 48 (abajo) -> 0 (arriba)
          final leftPawY = 48.0 * (1.0 - pawProgress);
          // Si está espiando (peeking), la pata derecha permanece abajo (48)
          final rightPawY = widget.peeking
              ? 48.0
              : 48.0 * (1.0 - pawProgress);

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  size: const Size(150, 150),
                  painter: _ReactivePetPainter(
                    lookAtEmail: widget.lookAtEmail,
                    blinkScaleY: blinkScaleY,
                    earLeftAngle: earLeftAngle,
                    earRightAngle: earRightAngle,
                    headTilt: headTilt,
                    leftPawY: leftPawY,
                    rightPawY: rightPawY,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReactivePetPainter extends CustomPainter {
  const _ReactivePetPainter({
    required this.lookAtEmail,
    required this.blinkScaleY,
    required this.earLeftAngle,
    required this.earRightAngle,
    required this.headTilt,
    required this.leftPawY,
    required this.rightPawY,
  });

  final bool lookAtEmail;
  final double blinkScaleY;
  final double earLeftAngle;
  final double earRightAngle;
  final double headTilt;
  final double leftPawY;
  final double rightPawY;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Ladeo de cabeza si aplica
    if (headTilt != 0.0) {
      canvas.translate(75, 110);
      canvas.rotate(headTilt);
      canvas.translate(-75, -110);
    }

    // 1. Oreja izquierda: M34 40C14 46 10 84 22 96c8-10 18-30 22-48z
    canvas.save();
    canvas.translate(34, 40);
    canvas.rotate(earLeftAngle);
    canvas.translate(-34, -40);
    final earLeft = Path()
      ..moveTo(34, 40)
      ..cubicTo(14, 46, 10, 84, 22, 96)
      ..cubicTo(30, 86, 40, 66, 44, 48)
      ..close();
    canvas.drawPath(earLeft, Paint()..color = PetTokens.dogEar);
    canvas.restore();

    // 2. Oreja derecha: M116 40c20 6 24 44 12 56-8-10-18-30-22-48z
    canvas.save();
    canvas.translate(116, 40);
    canvas.rotate(earRightAngle);
    canvas.translate(-116, -40);
    final earRight = Path()
      ..moveTo(116, 40)
      ..cubicTo(136, 46, 140, 84, 128, 96)
      ..cubicTo(120, 86, 110, 66, 106, 48)
      ..close();
    canvas.drawPath(earRight, Paint()..color = PetTokens.dogEar);
    canvas.restore();

    // 3. Cabeza: ellipse cx="75" cy="70" rx="44" ry="42"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(75, 70), width: 88, height: 84),
      Paint()..color = PetTokens.dogTan,
    );

    // 4. Mancha central frente: M75 30c-8 0-12 14-10 30h20c2-16-2-30-10-30z
    final forehead = Path()
      ..moveTo(75, 30)
      ..cubicTo(67, 30, 63, 44, 65, 60)
      ..lineTo(85, 60)
      ..cubicTo(87, 44, 83, 30, 75, 30)
      ..close();
    canvas.drawPath(forehead, Paint()..color = PetTokens.dogMuzzle);

    // 5. Hocico: ellipse cx="75" cy="92" rx="26" ry="20"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(75, 92), width: 52, height: 40),
      Paint()..color = PetTokens.dogMuzzle,
    );

    // 6. Ojos / Pupilas / Mirada / Parpadeo
    final pupilOffset = lookAtEmail ? const Offset(-3, 3) : Offset.zero;

    canvas.save();
    // Parpadeo con origen en (75, 68)
    canvas.translate(75, 68);
    canvas.scale(1.0, blinkScaleY);
    canvas.translate(-75, -68);

    // Ojo izquierdo (57, 68)
    canvas.drawCircle(
      const Offset(57, 68) + pupilOffset,
      6,
      Paint()..color = PetTokens.ink,
    );
    canvas.drawCircle(
      const Offset(59, 66) + pupilOffset,
      2,
      Paint()..color = Colors.white,
    );

    // Ojo derecho (93, 68)
    canvas.drawCircle(
      const Offset(93, 68) + pupilOffset,
      6,
      Paint()..color = PetTokens.ink,
    );
    canvas.drawCircle(
      const Offset(95, 66) + pupilOffset,
      2,
      Paint()..color = Colors.white,
    );
    canvas.restore();

    // 7. Nariz: ellipse cx="75" cy="84" rx="8" ry="5.5"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(75, 84), width: 16, height: 11),
      Paint()..color = PetTokens.ink,
    );

    // 8. Boca: M67 96q8 7 16 0
    final mouth = Path()
      ..moveTo(67, 96)
      ..quadraticBezierTo(75, 103, 83, 96);
    canvas.drawPath(
      mouth,
      Paint()
        ..color = PetTokens.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // 9. Lengüita: M71 99q4 10 8 0
    final tongue = Path()
      ..moveTo(71, 99)
      ..quadraticBezierTo(75, 109, 79, 99)
      ..close();
    canvas.drawPath(tongue, Paint()..color = PetTokens.clay);

    // 10. Collar: rect x="44" y="108" width="62" height="10" rx="5"
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 108, 62, 10),
        const Radius.circular(5),
      ),
      Paint()..color = PetTokens.clay,
    );

    // 11. Medalla dorada: circle cx="75" cy="122" r="6"
    canvas.drawCircle(const Offset(75, 122), 6, Paint()..color = PetTokens.tagGold);

    // 12. Patitas que se tapan los ojos
    final pawStroke = Paint()
      ..color = PetTokens.dogDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Pata izquierda: pl en (54, 70 + leftPawY)
    canvas.save();
    canvas.translate(0, leftPawY);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(54, 70), width: 36, height: 30),
      Paint()..color = PetTokens.dogTan,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(54, 70), width: 36, height: 30),
      pawStroke,
    );
    // Huellas uñas pata izq: M46 62v6M54 60v7M62 62v6
    canvas.drawLine(const Offset(46, 62), const Offset(46, 68), pawStroke);
    canvas.drawLine(const Offset(54, 60), const Offset(54, 67), pawStroke);
    canvas.drawLine(const Offset(62, 62), const Offset(62, 68), pawStroke);
    canvas.restore();

    // Pata derecha: pr en (96, 70 + rightPawY)
    canvas.save();
    canvas.translate(0, rightPawY);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(96, 70), width: 36, height: 30),
      Paint()..color = PetTokens.dogTan,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(96, 70), width: 36, height: 30),
      pawStroke,
    );
    // Huellas uñas pata der: M88 62v6M96 60v7M104 62v6
    canvas.drawLine(const Offset(88, 62), const Offset(88, 68), pawStroke);
    canvas.drawLine(const Offset(96, 60), const Offset(96, 67), pawStroke);
    canvas.drawLine(const Offset(104, 62), const Offset(104, 68), pawStroke);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReactivePetPainter oldDelegate) {
    return oldDelegate.lookAtEmail != lookAtEmail ||
        oldDelegate.blinkScaleY != blinkScaleY ||
        oldDelegate.earLeftAngle != earLeftAngle ||
        oldDelegate.earRightAngle != earRightAngle ||
        oldDelegate.headTilt != headTilt ||
        oldDelegate.leftPawY != leftPawY ||
        oldDelegate.rightPawY != rightPawY;
  }
}

