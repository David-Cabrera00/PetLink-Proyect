import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/widgets/pet_paw_painters.dart';

class ReportPublishedScreen extends StatefulWidget {
  const ReportPublishedScreen({super.key});

  @override
  State<ReportPublishedScreen> createState() => _ReportPublishedScreenState();
}

class _ReportPublishedScreenState extends State<ReportPublishedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: PetTokens.plum,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ilustración de ondas expansivas de alerta y casita con huella
              SizedBox(
                width: 240,
                height: 240,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _AlertWavesPainter(progress: _waveController.value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Título según Paso6Publicar.dc.html
              Text(
                l10n.reportPublishedTitle,
                style: PetTokens.display(34, color: PetTokens.cream),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Mensaje descriptivo
              Text(
                l10n.reportPublishedDescription,
                style: PetTokens.body(
                  15,
                  color: const Color(0xFFD9C8D3),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Botón principal: Ir al radar
              InkWell(
                onTap: () => context.go('/radar'),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: PetTokens.cream,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 10),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.navigationRadar,
                        style: PetTokens.body(
                          16,
                          color: PetTokens.plum,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: PetTokens.plum,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón secundario: Ver mis reportes
              InkWell(
                onTap: () => context.go('/reports/mine'),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF8A6A8A),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.viewMyReport,
                    style: PetTokens.body(
                      15,
                      color: PetTokens.cream,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertWavesPainter extends CustomPainter {
  const _AlertWavesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 3 ondas expansivas en color peach (#F29A7E)
    for (int i = 0; i < 3; i++) {
      final p = (progress + (i * 0.333)) % 1.0;
      final radius = 50.0 + 65.0 * p;
      final opacity = (1.0 - p).clamp(0.0, 1.0);

      final wavePaint = Paint()
        ..color = const Color(0xFFF29A7E).withValues(alpha: opacity * 0.7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, radius, wavePaint);
    }

    // Círculo base crema central
    final baseCircle = Paint()
      ..color = PetTokens.cream
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 52, baseCircle);

    // Casita ciruela en el centro
    final housePaint = Paint()
      ..color = PetTokens.plum
      ..style = PaintingStyle.fill;

    final roof = Path()
      ..moveTo(center.dx - 26, center.dy + 4)
      ..lineTo(center.dx, center.dy - 20)
      ..lineTo(center.dx + 26, center.dy + 4)
      ..close();
    canvas.drawPath(roof, housePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 14), width: 36, height: 22),
        const Radius.circular(2),
      ),
      housePaint,
    );

    // Huella terracota en la casita
    canvas.save();
    canvas.translate(center.dx - 9, center.dy + 4);
    const PawPainter(color: PetTokens.clay).paint(canvas, const Size(18, 18));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AlertWavesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
