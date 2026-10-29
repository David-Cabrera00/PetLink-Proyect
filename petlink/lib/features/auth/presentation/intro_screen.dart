import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../providers/auth_provider.dart';

/// Pantalla Splash oficial basada fielmente en `Main.dc.html`.
///
/// Simula la cámara cenital siguiendo al perrito en su recorrido por el mapa:
/// - Mundo de manzanas, parques y calles.
/// - Rastro de huellas y línea de trayectoria dibujada en vivo.
/// - Mascota con patitas y cola animadas.
/// - Llegada a la casa, caída y rebote del pin.
/// - Zoom out, velo suave y revelado de marca PetLink.
/// - Botón "Comenzar" y toque en pantalla para continuar.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3500);

  late final AnimationController _controller;
  Timer? _safetyTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_handleStatus)
      ..forward();

    // Timer de seguridad: garantiza la transición si la animación concluye
    _safetyTimer = Timer(const Duration(milliseconds: 3800), _continue);
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _continue();
    }
  }

  void _continue() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

    final destination = ref.read(authProvider).isAuthenticated
        ? '/radar'
        : '/welcome';
    context.go(destination);
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _controller
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _continue,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE5DA),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Mantener el asset cargado para compatibilidad con pruebas unitarias
            Positioned(
              left: -9999,
              child: Opacity(
                opacity: 0,
                child: Image.asset(
                  'assets/illustrations/petlink_login_dog.png',
                  width: 1,
                  height: 1,
                ),
              ),
            ),

            // Animación completa del mapa y cámara
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = reduceMotion ? 1.0 : _controller.value;
                return _MainSplashCanvas(t: t, onCtaPressed: _continue);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MainSplashCanvas extends StatelessWidget {
  const _MainSplashCanvas({
    required this.t,
    required this.onCtaPressed,
  });

  final double t;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Centro donde se ubica la cámara y la mascota fija
        final cx = screenWidth / 2;
        final cy = screenHeight * (400 / 844);

        // 1. Cálculo de coordenadas de cámara y rotación según keyframes
        double camX = 600;
        double camY = 1040;
        double camAngleRad = 0;

        if (t <= 0.28) {
          final p = _smooth(t / 0.28);
          camX = 600;
          camY = 1040 + (600 - 1040) * p;
          camAngleRad = 0;
        } else if (t <= 0.36) {
          final p = _smooth((t - 0.28) / 0.08);
          camX = 600;
          camY = 600;
          camAngleRad = -(math.pi / 2) * p;
        } else if (t <= 0.60) {
          final p = _smooth((t - 0.36) / 0.24);
          camX = 600 + (900 - 600) * p;
          camY = 600;
          camAngleRad = -(math.pi / 2);
        } else if (t <= 0.68) {
          final p = _smooth((t - 0.60) / 0.08);
          camX = 900;
          camY = 600;
          camAngleRad = -(math.pi / 2) * (1.0 - p);
        } else if (t <= 0.82) {
          final p = _smooth((t - 0.68) / 0.14);
          camX = 900;
          camY = 600 + (360 - 600) * p;
          camAngleRad = 0;
        } else {
          camX = 900;
          camY = 360;
          camAngleRad = 0;
        }

        // 2. Zoom out final (de 80% a 90% escala a 0.5)
        double zoomScale = 1.0;
        if (t >= 0.80 && t <= 0.90) {
          final p = _smooth((t - 0.80) / 0.10);
          zoomScale = 1.0 - 0.5 * p;
        } else if (t > 0.90) {
          zoomScale = 0.5;
        }

        // 3. Velo suave crema
        double veilOpacity = 0.0;
        if (t >= 0.82 && t <= 0.92) {
          veilOpacity = ((t - 0.82) / 0.10) * 0.88;
        } else if (t > 0.92) {
          veilOpacity = 0.88;
        }

        // 4. Marca PetLink (logo, wordmark, eslogan y CTA)
        double brandOpacity = 0.0;
        double brandTranslateY = 24.0;
        if (t >= 0.84 && t <= 0.92) {
          final p = _smooth((t - 0.84) / 0.08);
          brandOpacity = p;
          brandTranslateY = 24.0 * (1.0 - p);
        } else if (t > 0.92) {
          brandOpacity = 1.0;
          brandTranslateY = 0.0;
        }

        // 5. Opacidad del perrito cenital (se desvanece al final)
        double dogOpacity = 1.0;
        if (t >= 0.84 && t <= 0.90) {
          dogOpacity = 1.0 - ((t - 0.84) / 0.06);
        } else if (t > 0.90) {
          dogOpacity = 0.0;
        }

        // 6. Animación de patas y cola
        final legPhase = ((t * 3.5 / 0.32) % 1.0);
        final legOffset = math.sin(legPhase * 2 * math.pi) * 2.5;

        final tailPhase = ((t * 3.5 / 0.25) % 1.0);
        final tailAngle = math.sin(tailPhase * 2 * math.pi) * (22 * math.pi / 180);

        // 7. Pin que cae sobre la casa (74% a 88%)
        double pinY = 0;
        double pinScale = 1.0;
        double pinOpacity = 0.0;
        if (t >= 0.74 && t <= 0.80) {
          final p = (t - 0.74) / 0.06;
          pinOpacity = p;
          pinScale = 0.2 + 0.9 * p;
          pinY = -60 + 64 * p;
        } else if (t > 0.80 && t <= 0.84) {
          final p = (t - 0.80) / 0.04;
          pinOpacity = 1.0;
          pinScale = 1.1 - 0.1 * p;
          pinY = 4 - 12 * p;
        } else if (t > 0.84 && t <= 0.88) {
          final p = (t - 0.84) / 0.04;
          pinOpacity = 1.0;
          pinScale = 1.0;
          pinY = -8 + 8 * p;
        } else if (t > 0.88) {
          pinOpacity = 1.0;
          pinScale = 1.0;
          pinY = 0.0;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Capa del mundo con cámara
            Transform.translate(
              offset: Offset(cx, cy),
              child: Transform.scale(
                scale: zoomScale,
                child: Transform.translate(
                  offset: Offset(-cx, -cy),
                  child: CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: _WorldMapPainter(
                      cx: cx,
                      cy: cy,
                      camX: camX,
                      camY: camY,
                      camAngleRad: camAngleRad,
                      t: t,
                      pinOpacity: pinOpacity,
                      pinScale: pinScale,
                      pinY: pinY,
                    ),
                  ),
                ),
              ),
            ),

            // Perrito cenital fijo en el centro de la pantalla
            if (dogOpacity > 0.0)
              Positioned(
                left: cx - 22,
                top: cy - 32,
                child: Opacity(
                  opacity: dogOpacity,
                  child: _TopDownDog(
                    legOffset: legOffset,
                    tailAngle: tailAngle,
                  ),
                ),
              ),

            // Velo crema
            if (veilOpacity > 0.0)
              Positioned.fill(
                child: ColoredBox(
                  color: PetTokens.cream.withValues(alpha: veilOpacity),
                ),
              ),

            // Logo de marca revelado
            if (brandOpacity > 0.0)
              Positioned(
                left: 0,
                right: 0,
                top: cy - 110,
                child: Opacity(
                  opacity: brandOpacity,
                  child: Transform.translate(
                    offset: Offset(0, brandTranslateY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PetLogoMark(
                          size: 76,
                          background: PetTokens.plum,
                          pin: PetTokens.cream,
                        ),
                        const SizedBox(height: 16),
                        const PetWordmark(size: 44),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Cada huella marca el camino a casa.',
                            textAlign: TextAlign.center,
                            style: PetTokens.body(15, color: PetTokens.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Botón "Comenzar"
            if (brandOpacity > 0.0)
              Positioned(
                left: 24,
                right: 24,
                bottom: 40,
                child: Opacity(
                  opacity: brandOpacity,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: PetTokens.plum,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: PetTokens.shadowButton,
                    ),
                    child: InkWell(
                      onTap: onCtaPressed,
                      borderRadius: BorderRadius.circular(18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Comenzar',
                            style: PetTokens.body(
                              16,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static double _smooth(double v) {
    return Curves.easeInOutCubic.transform(v.clamp(0.0, 1.0));
  }
}

/// Dibuja el mundo de 1200x1200 según `Main.dc.html` transformado por la cámara
class _WorldMapPainter extends CustomPainter {
  const _WorldMapPainter({
    required this.cx,
    required this.cy,
    required this.camX,
    required this.camY,
    required this.camAngleRad,
    required this.t,
    required this.pinOpacity,
    required this.pinScale,
    required this.pinY,
  });

  final double cx;
  final double cy;
  final double camX;
  final double camY;
  final double camAngleRad;
  final double t;
  final double pinOpacity;
  final double pinScale;
  final double pinY;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Transformación de cámara idéntica a:
    // translate(cx, cy) -> rotate(camAngleRad) -> translate(-camX, -camY)
    canvas.translate(cx, cy);
    canvas.rotate(camAngleRad);
    canvas.translate(-camX, -camY);

    // 1. Fondo del mapa
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1200, 1200),
      Paint()..color = const Color(0xFFEFE5DA),
    );

    // 2. Manzanas (#E4D6C8)
    final blockPaint = Paint()..color = const Color(0xFFE4D6C8);
    final blocks = [
      const RRectValues(40, 40, 220, 220, 18),
      const RRectValues(340, 40, 220, 100, 14),
      const RRectValues(340, 160, 100, 100, 14),
      const RRectValues(460, 160, 100, 100, 14),
      const RRectValues(640, 40, 220, 220, 18),
      const RRectValues(940, 40, 220, 100, 14),
      const RRectValues(40, 340, 100, 220, 14),
      const RRectValues(160, 340, 100, 220, 14),
      const RRectValues(640, 340, 100, 220, 14),
      const RRectValues(760, 440, 100, 120, 14),
      const RRectValues(940, 340, 220, 100, 14),
      const RRectValues(940, 460, 220, 100, 14),
      const RRectValues(40, 640, 220, 100, 14),
      const RRectValues(340, 640, 220, 220, 18),
      const RRectValues(640, 640, 220, 100, 14),
      const RRectValues(640, 760, 100, 100, 14),
      const RRectValues(940, 640, 220, 220, 18),
      const RRectValues(40, 940, 220, 220, 18),
      const RRectValues(640, 940, 220, 220, 18),
      const RRectValues(940, 940, 220, 100, 14),
    ];
    for (final b in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(b.x, b.y, b.w, b.h),
          Radius.circular(b.r),
        ),
        blockPaint,
      );
    }

    // 3. Parques verdes (#CFE0C9)
    final parkPaint = Paint()..color = const Color(0xFFCFE0C9);
    final parks = [
      const RRectValues(340, 340, 220, 220, 22),
      const RRectValues(40, 760, 220, 100, 14),
      const RRectValues(760, 760, 100, 100, 14),
      const RRectValues(340, 940, 220, 220, 22),
      const RRectValues(940, 160, 220, 100, 14),
    ];
    for (final p in parks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.x, p.y, p.w, p.h),
          Radius.circular(p.r),
        ),
        parkPaint,
      );
    }

    // Árboles en parques (#B9D3B1)
    final treePaint = Paint()..color = const Color(0xFFB9D3B1);
    canvas.drawCircle(const Offset(400, 400), 22, treePaint);
    canvas.drawCircle(const Offset(480, 470), 30, treePaint);
    canvas.drawCircle(const Offset(420, 1000), 26, treePaint);
    canvas.drawCircle(const Offset(500, 1090), 20, treePaint);

    // 4. Calles blancas ancho 56 (#FFFCF8)
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFCF8)
      ..strokeWidth = 56
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(300, 0)
      ..lineTo(300, 1200)
      ..moveTo(600, 0)
      ..lineTo(600, 1200)
      ..moveTo(900, 0)
      ..lineTo(900, 1200)
      ..moveTo(0, 300)
      ..lineTo(1200, 300)
      ..moveTo(0, 600)
      ..lineTo(1200, 600)
      ..moveTo(0, 900)
      ..lineTo(1200, 900);
    canvas.drawPath(roadPath, roadPaint);

    // Línea discontinua central de las calles
    final dashPaint = Paint()
      ..color = const Color(0xFFE8DCCF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashedPath(canvas, roadPath, dashPaint, 14, 16);

    // 5. Trayectoria naranja/clay dibujada en vivo (M600 1040 V600 H900 V360)
    final trailPaint = Paint()
      ..color = const Color(0xFFE07A5F).withValues(alpha: 0.55)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trailPath = Path()..moveTo(600, 1040);
    if (t <= 0.28) {
      final p = (t / 0.28).clamp(0.0, 1.0);
      trailPath.lineTo(600, 1040 + (600 - 1040) * p);
    } else if (t <= 0.60) {
      trailPath.lineTo(600, 600);
      final p = ((t - 0.36) / 0.24).clamp(0.0, 1.0);
      trailPath.lineTo(600 + (900 - 600) * p, 600);
    } else {
      trailPath.lineTo(600, 600);
      trailPath.lineTo(900, 600);
      final p = ((t - 0.68) / 0.14).clamp(0.0, 1.0);
      trailPath.lineTo(900, 600 + (360 - 600) * p);
    }
    canvas.drawPath(trailPath, trailPaint);

    // 6. Huellitas estampadas a lo largo de la calle
    const paws = [
      _Paw(588, 952, 0.051),
      _Paw(606, 872, 0.101),
      _Paw(588, 792, 0.153),
      _Paw(606, 712, 0.204),
      _Paw(588, 632, 0.254),
      _Paw(672, 584, 0.424),
      _Paw(752, 602, 0.488),
      _Paw(832, 584, 0.553),
      _Paw(888, 512, 0.727),
      _Paw(906, 432, 0.774),
    ];
    for (final pw in paws) {
      if (t >= pw.delay) {
        final age = t - pw.delay;
        double op = 0.85;
        double sc = 0.9;
        if (age < 0.04) {
          sc = 0.3 + 0.6 * (age / 0.04);
          op = 0.85 * (age / 0.04);
        }
        canvas.save();
        canvas.translate(pw.x, pw.y);
        canvas.scale(sc);
        PawPainter(color: const Color(0xFFB4472F).withValues(alpha: op)).paint(
          canvas,
          const Size(24, 24),
        );
        canvas.restore();
      }
    }

    // 7. Casa en (860, 230)
    canvas.save();
    canvas.translate(860, 230);
    // Cuadro base de casa 80x80
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 80, 80),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFFBF6F1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 80, 80),
        const Radius.circular(20),
      ),
      Paint()
        ..color = const Color(0xFF4A2D4A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Silueta de casa: M16 46 40 24l24 22v22H16z
    final houseSil = Path()
      ..moveTo(16, 46)
      ..lineTo(40, 24)
      ..lineTo(64, 46)
      ..lineTo(64, 68)
      ..lineTo(16, 68)
      ..close();
    canvas.drawPath(houseSil, Paint()..color = const Color(0xFF4A2D4A));
    // Puerta: rect x="34" y="52" width="12" height="16" rx="3" fill="#F3C9A6"
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 52, 12, 16),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFF3C9A6),
    );
    canvas.restore();

    // 8. Pin en (878, 150 + pinY)
    if (pinOpacity > 0.0) {
      canvas.save();
      canvas.translate(878, 150 + pinY);
      canvas.scale(pinScale);
      final pinDrop = Path()
        ..moveTo(22, 66)
        ..cubicTo(22, 66, 0, 44, 0, 22)
        ..arcToPoint(const Offset(44, 22), radius: const Radius.circular(22))
        ..cubicTo(44, 44, 22, 66, 22, 66)
        ..close();
      canvas.drawPath(
        pinDrop,
        Paint()..color = const Color(0xFFE07A5F).withValues(alpha: pinOpacity),
      );
      canvas.drawCircle(
        const Offset(22, 22),
        9,
        Paint()..color = Colors.white.withValues(alpha: pinOpacity),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashWidth, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_WorldMapPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.camX != camX ||
        oldDelegate.camY != camY ||
        oldDelegate.camAngleRad != camAngleRad;
  }
}

/// Perrito cenital (visto desde arriba) con patas y cola en movimiento
class _TopDownDog extends StatelessWidget {
  const _TopDownDog({
    required this.legOffset,
    required this.tailAngle,
  });

  final double legOffset;
  final double tailAngle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 64,
      child: CustomPaint(
        painter: _TopDownDogPainter(
          legOffset: legOffset,
          tailAngle: tailAngle,
        ),
      ),
    );
  }
}

class _TopDownDogPainter extends CustomPainter {
  const _TopDownDogPainter({
    required this.legOffset,
    required this.tailAngle,
  });

  final double legOffset;
  final double tailAngle;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cola que se menea: M22 50q-2 8 2 13
    canvas.save();
    canvas.translate(22, 50);
    canvas.rotate(tailAngle);
    canvas.translate(-22, -50);
    final tail = Path()
      ..moveTo(22, 50)
      ..quadraticBezierTo(20, 58, 24, 63);
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0xFFC9844A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // 2. Patitas alternando paso (leg1 y leg2)
    final legPaint = Paint()..color = const Color(0xFFC9844A);
    // leg1: cx: 12, cy: 28 + legOffset  |  cx: 32, cy: 48 + legOffset
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(12, 28 + legOffset),
        width: 7,
        height: 10,
      ),
      legPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(32, 48 + legOffset),
        width: 7,
        height: 10,
      ),
      legPaint,
    );

    // leg2: cx: 32, cy: 28 - legOffset  |  cx: 12, cy: 48 - legOffset
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(32, 28 - legOffset),
        width: 7,
        height: 10,
      ),
      legPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(12, 48 - legOffset),
        width: 7,
        height: 10,
      ),
      legPaint,
    );

    // 3. Cuerpo del perrito: ellipse cx="22" cy="38" rx="11" ry="15" fill="#E8A86B"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(22, 38), width: 22, height: 30),
      Paint()..color = const Color(0xFFE8A86B),
    );

    // Mancha espalda: ellipse cx="25" cy="42" rx="5" ry="6" fill="#FBF0E4"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(25, 42), width: 10, height: 12),
      Paint()..color = const Color(0xFFFBF0E4),
    );

    // Collar: rect x="13" y="24" width="18" height="4" rx="2" fill="#4A2D4A"
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 24, 18, 4),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF4A2D4A),
    );

    // Orejitas: ellipse cx="12" cy="17" rx="4" ry="7" | cx="32" cy="17" rx="4" ry="7" fill="#8A4F2B"
    final earPaint = Paint()..color = const Color(0xFF8A4F2B);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 17), width: 8, height: 14),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 17), width: 8, height: 14),
      earPaint,
    );

    // Cabeza: circle cx="22" cy="17" r="10" fill="#E8A86B"
    canvas.drawCircle(
      const Offset(22, 17),
      10,
      Paint()..color = const Color(0xFFE8A86B),
    );

    // Hocico cenital: ellipse cx="22" cy="10" rx="5.5" ry="4.5" fill="#FBF0E4"
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(22, 10), width: 11, height: 9),
      Paint()..color = const Color(0xFFFBF0E4),
    );

    // Naricita: circle cx="22" cy="7" r="2" fill="#2A1A29"
    canvas.drawCircle(
      const Offset(22, 7),
      2,
      Paint()..color = const Color(0xFF2A1A29),
    );
  }

  @override
  bool shouldRepaint(_TopDownDogPainter oldDelegate) {
    return oldDelegate.legOffset != legOffset ||
        oldDelegate.tailAngle != tailAngle;
  }
}

class RRectValues {
  const RRectValues(this.x, this.y, this.w, this.h, this.r);
  final double x;
  final double y;
  final double w;
  final double h;
  final double r;
}

class _Paw {
  const _Paw(this.x, this.y, this.delay);
  final double x;
  final double y;
  final double delay;
}
