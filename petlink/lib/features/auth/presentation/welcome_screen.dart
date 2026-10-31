import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/widgets/pet_paw_painters.dart';

/// Huella del rastro en coordenadas del diseño (lienzo de 390 px de ancho).
class _Step {
  const _Step(this.x, this.y, this.deg);
  final double x;
  final double y;
  final double deg;
}

const _walk = <_Step>[
  _Step(40, 470, -35),
  _Step(84, 432, -35),
  _Step(110, 380, -25),
  _Step(152, 348, -15),
  _Step(176, 296, 0),
  _Step(220, 268, 15),
  _Step(240, 214, 25),
  _Step(284, 196, 35),
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _seconds = ValueNotifier<double>(0);
  bool _reduceMotionApplied = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _seconds.value = elapsed.inMicroseconds / 1e6;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotionApplied) return;
    _reduceMotionApplied = true;
    if (MediaQuery.of(context).disableAnimations) {
      // Estado final, sin animar.
      _seconds.value = 3.0;
    } else {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eyebrow = l10n.welcomeEyebrow;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: PetTokens.plumDeep,
      body: LayoutBuilder(
        builder: (context, c) {
          final s = c.maxWidth / 390;

          return ValueListenableBuilder<double>(
            valueListenable: _seconds,
            builder: (context, sec, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _Topo(sec: sec),
                  _Walk(sec: sec, scale: s),
                  _FloatingPin(sec: sec, scale: s),
                  Positioned(
                    left: 24,
                    top: top + 14,
                    child: Row(
                      children: [
                        const PetLogoMark(size: 40),
                        const SizedBox(width: 10),
                        Text(
                          'PetLink',
                          style: PetTokens.display(
                            20,
                            color: PetTokens.cream,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Rise(
                              sec: sec,
                              delay: 0.1,
                              child: Text(
                                eyebrow.toUpperCase(),
                                style: PetTokens.eyebrow(color: PetTokens.peach),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Rise(
                              sec: sec,
                              delay: 0.2,
                              child: Text(
                                l10n.authWelcomeTitle,
                                style: PetTokens.display(
                                  42,
                                  color: PetTokens.cream,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Rise(
                              sec: sec,
                              delay: 0.35,
                              child: Text(
                                l10n.authWelcomeDescription,
                                style: PetTokens.body(
                                  16,
                                  color: PetTokens.lilacText,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _Rise(
                              sec: sec,
                              delay: 0.5,
                              child: _WelcomeButton(
                                label: l10n.authLogin,
                                filled: true,
                                onTap: () => context.go('/login'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Rise(
                              sec: sec,
                              delay: 0.6,
                              child: _WelcomeButton(
                                label: l10n.authCreateAccount,
                                filled: false,
                                onTap: () => context.go('/register'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

}

/// Entrada escalonada: opacidad 0→1 y translateY 22→0 en 700 ms.
class _Rise extends StatelessWidget {
  const _Rise({required this.sec, required this.delay, required this.child});

  final double sec;
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = PetTokens.rise.transform(((sec - delay) / 0.7).clamp(0.0, 1.0));
    return Opacity(
      opacity: p,
      child: Transform.translate(offset: Offset(0, 22 * (1 - p)), child: child),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? PetTokens.plumDeep : PetTokens.cream;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? PetTokens.cream : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PetTokens.rButton),
          side: filled
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF6E4E6E), width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PetTokens.rButton),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: PetTokens.body(16, color: fg, weight: FontWeight.w700),
                ),
                if (filled) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contornos topográficos que giran y derivan lentamente (18 s alterno).
class _Topo extends StatelessWidget {
  const _Topo({required this.sec});

  final double sec;

  @override
  Widget build(BuildContext context) {
    final cycle = (sec / 18) % 2;
    final tri = 1 - (cycle - 1).abs();
    final u = Curves.easeInOut.transform(tri);

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(-120 - 20 * u, -80 + 30 * u),
        child: Transform.rotate(
          angle: 8 * math.pi / 180 * u,
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              child: CustomPaint(
                size: const Size(640, 640),
                painter: const _TopoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopoPainter extends CustomPainter {
  const _TopoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4E3250)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Path ring(
      double sx,
      double sy,
      List<List<double>> c,
    ) {
      final p = Path()..moveTo(sx, sy);
      for (final v in c) {
        p.cubicTo(v[0], v[1], v[2], v[3], v[4], v[5]);
      }
      return p..close();
    }

    // M320 60c120 0 250 80 250 220s-110 290-250 290S70 470 70 320 200 60 320 60z
    canvas.drawPath(
      ring(320, 60, [
        [440, 60, 570, 140, 570, 280],
        [570, 420, 460, 570, 320, 570],
        [180, 570, 70, 470, 70, 320],
        [70, 170, 200, 60, 320, 60],
      ]),
      paint,
    );
    // M320 110c95 0 200 70 200 180s-90 230-200 230-200-90-200-210 105-200 200-200z
    canvas.drawPath(
      ring(320, 110, [
        [415, 110, 520, 180, 520, 290],
        [520, 400, 430, 520, 320, 520],
        [210, 520, 120, 430, 120, 310],
        [120, 190, 225, 110, 320, 110],
      ]),
      paint,
    );
    // M320 160c75 0 150 55 150 135s-65 175-150 175-150-70-150-160 75-150 150-150z
    canvas.drawPath(
      ring(320, 160, [
        [395, 160, 470, 215, 470, 295],
        [470, 375, 405, 470, 320, 470],
        [235, 470, 170, 400, 170, 310],
        [170, 220, 245, 160, 320, 160],
      ]),
      paint,
    );
    // M320 210c50 0 100 40 100 90s-45 120-100 120-100-50-100-110 50-100 100-100z
    canvas.drawPath(
      ring(320, 210, [
        [370, 210, 420, 250, 420, 300],
        [420, 350, 375, 420, 320, 420],
        [265, 420, 220, 370, 220, 310],
        [220, 260, 270, 210, 320, 210],
      ]),
      paint,
    );
    // M320 258c28 0 52 22 52 48s-24 62-52 62-52-28-52-58 24-52 52-52z
    canvas.drawPath(
      ring(320, 258, [
        [348, 258, 372, 280, 372, 306],
        [372, 332, 348, 368, 320, 368],
        [292, 368, 268, 340, 268, 310],
        [268, 280, 292, 258, 320, 258],
      ]),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TopoPainter oldDelegate) => false;
}

/// Ocho huellas que se estampan en diagonal (una cada 0.4 s, bucle de 6 s).
class _Walk extends StatelessWidget {
  const _Walk({required this.sec, required this.scale});

  final double sec;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (var i = 0; i < _walk.length; i++) _paw(i),
        ],
      ),
    );
  }

  Widget _paw(int i) {
    final step = _walk[i];
    final local = sec - i * 0.4;
    double opacity = 0;
    double pawScale = 0.4;
    if (local >= 0) {
      final ph = (local % 6) / 6;
      if (ph < 0.04) {
        final k = ph / 0.04;
        opacity = 0.9 * k;
        pawScale = 0.4 + 0.6 * k;
      } else if (ph < 0.40) {
        final k = (ph - 0.04) / 0.36;
        opacity = 0.9 - 0.3 * k;
        pawScale = 1;
      } else if (ph < 0.70) {
        final k = (ph - 0.40) / 0.30;
        opacity = 0.6 * (1 - k);
        pawScale = 1;
      }
    }
    final size = 24 * scale;
    return Positioned(
      left: step.x * scale,
      top: step.y * scale,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: step.deg * math.pi / 180,
          child: Transform.scale(
            scale: pawScale,
            child: PetPaw(size: size, color: PetTokens.clay),
          ),
        ),
      ),
    );
  }
}

/// Pin con casa que flota (3.2 s) y anillo que se expande (2.6 s).
class _FloatingPin extends StatelessWidget {
  const _FloatingPin({required this.sec, required this.scale});

  final double sec;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final bob = Curves.easeInOut.transform(
      1 - ((sec / 3.2) % 1 * 2 - 1).abs(),
    );
    final ringP = (sec / 2.6) % 1;
    final ringScale = 0.4 + 2.0 * ringP;
    final ringOpacity = 0.7 * (1 - ringP);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: (318 - 18) * scale,
            top: (168 - 18) * scale,
            child: Opacity(
              opacity: ringOpacity,
              child: Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: PetTokens.clay, width: 2),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 296 * scale,
            top: 104 * scale - 10 * bob,
            child: PetPin(width: 44 * scale),
          ),
        ],
      ),
    );
  }
}
