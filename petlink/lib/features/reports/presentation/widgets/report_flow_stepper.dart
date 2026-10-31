import 'package:petlink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/pet_tokens.dart';
import '../../../../shared/widgets/pet_paw_painters.dart';

class ReportFlowStepper extends StatefulWidget {
  const ReportFlowStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
    this.stepTitle,
    required this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final String? stepTitle;
  final VoidCallback onBack;

  @override
  State<ReportFlowStepper> createState() => _ReportFlowStepperState();
}

class _ReportFlowStepperState extends State<ReportFlowStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stepPrefix = l10n.stepPrefix;
    final ofPrefix = l10n.ofPrefix;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fila superior: Botón volver + Etiqueta de paso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: widget.onBack,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PetTokens.surfaceOf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: PetTokens.borderOf(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: PetTokens.inkOf(context),
                    size: 22,
                  ),
                ),
              ),
              Text(
                widget.stepTitle != null && widget.stepTitle!.isNotEmpty
                    ? '$stepPrefix ${widget.currentStep} $ofPrefix ${widget.totalSteps} \u00B7 ${widget.stepTitle}'
                    : '$stepPrefix ${widget.currentStep} $ofPrefix ${widget.totalSteps}',
                style: PetTokens.bodyThemed(
                  context,
                  13,
                  color: PetTokens.mutedOf(context),
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 44), // Espaciador para centrar el texto
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Barra gráfica curva con nodos de huellas y casita final
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter),
          child: SizedBox(
            height: 40,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: _StepperTrackPainter(
                    currentStep: widget.currentStep,
                    totalSteps: widget.totalSteps,
                    pulseValue: _pulseController.value,
                    isDark: PetTokens.isDark(context),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperTrackPainter extends CustomPainter {
  const _StepperTrackPainter({
    required this.currentStep,
    required this.totalSteps,
    required this.pulseValue,
    required this.isDark,
  });

  final int currentStep;
  final int totalSteps;
  final double pulseValue;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final startX = 14.0;
    final endX = size.width - 24.0;
    final trackWidth = endX - startX;
    final stepDistance = trackWidth / totalSteps;

    // 1. Línea base discontinua
    final dashedPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2432) : const Color(0xFFDCCFC4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final baseTrack = Path()..moveTo(startX, 22);
    for (int i = 1; i <= totalSteps; i++) {
      final x = startX + i * stepDistance;
      baseTrack.lineTo(x, 22);
    }
    _drawDashedPath(canvas, baseTrack, dashedPaint, 3.0, 6.0);

    // 2. Línea sólida de avance completado
    if (currentStep > 1) {
      final completedX = startX + (currentStep - 1) * stepDistance;
      final solidPaint = Paint()
        ..color = isDark ? const Color(0xFFD8AED6) : PetTokens.plum
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(startX, 22), Offset(completedX, 22), solidPaint);
    }

    // 3. Nodos de huellas (1 a 6)
    for (int i = 1; i <= totalSteps; i++) {
      final nodeX = startX + (i - 1) * stepDistance;
      final nodeY = 22.0;

      if (i < currentStep) {
        // Pasos completados: huella ciruela
        canvas.save();
        canvas.translate(nodeX - 8, nodeY - 8);
        PawPainter(color: isDark ? const Color(0xFFD8AED6) : PetTokens.plum).paint(canvas, const Size(16, 16));
        canvas.restore();
      } else if (i == currentStep) {
        // Paso actual: anillo pulsante + huella terracota
        final pulseRadius = 10.0 + 8.0 * pulseValue;
        final pulseOpacity = (1.0 - pulseValue).clamp(0.0, 1.0);
        final pulsePaint = Paint()
          ..color = PetTokens.clay.withValues(alpha: pulseOpacity * 0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(nodeX, nodeY), pulseRadius, pulsePaint);

        canvas.save();
        canvas.translate(nodeX - 9, nodeY - 9);
        const PawPainter(color: PetTokens.clay)
            .paint(canvas, const Size(18, 18));
        canvas.restore();
      } else {
        // Pasos futuros: huella gris suave
        canvas.save();
        canvas.translate(nodeX - 8, nodeY - 8);
        PawPainter(color: isDark ? const Color(0xFF362D3B) : const Color(0xFFE3D6CB))
            .paint(canvas, const Size(16, 16));
        canvas.restore();
      }
    }

    // 4. Casita al final del sendero
    final houseX = endX;
    final houseY = 22.0;
    final isDone = currentStep >= totalSteps;
    final houseColor = isDone ? PetTokens.clay : (isDark ? const Color(0xFF362D3B) : const Color(0xFFE3D6CB));

    final housePaint = Paint()
      ..color = houseColor
      ..style = PaintingStyle.fill;

    final roof = Path()
      ..moveTo(houseX - 8, houseY + 4)
      ..lineTo(houseX, houseY - 6)
      ..lineTo(houseX + 8, houseY + 4)
      ..close();
    canvas.drawPath(roof, housePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(houseX - 6, houseY + 4, 12, 10),
        const Radius.circular(1),
      ),
      housePaint,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double dashSpace,
  ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StepperTrackPainter oldDelegate) =>
      oldDelegate.currentStep != currentStep ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.isDark != isDark;
}
