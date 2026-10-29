import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../providers/report_draft_provider.dart';
import 'widgets/report_flow_stepper.dart';

class ReportTypeScreen extends ConsumerStatefulWidget {
  const ReportTypeScreen({super.key});

  @override
  ConsumerState<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends ConsumerState<ReportTypeScreen> {
  ReportType? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = ref.read(reportDraftProvider).reportType;
  }

  void _onSelect(ReportType type) {
    setState(() => _selectedType = type);
    ref.read(reportDraftProvider.notifier).setReportType(type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSelection = _selectedType != null;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 1 de 6
            ReportFlowStepper(
              currentStep: 1,
              stepTitle: l10n.reportWhatHappened,
              onBack: () {
                ref.read(reportDraftProvider.notifier).clearDraft();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/reports');
                }
              },
            ),

            // Contenido escroleable
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PetTokens.gutter,
                  16,
                  PetTokens.gutter,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.reportWhatHappened,
                      style: PetTokens.displayThemed(context, 34),
                    ),
                    const SizedBox(height: 24),

                    // Opción A: Perdí a mi mascota
                    _OptionCard(
                      isSelected: _selectedType == ReportType.lost,
                      borderColor: PetTokens.clayText,
                      selectedBg: PetTokens.isDark(context)
                          ? const Color(0xFF381C22)
                          : const Color(0xFFFCEEE8),
                      artWidget: const _SwingingLeashArt(),
                      title: l10n.reportLostTitle,
                      subtitle: l10n.reportLostDescription,
                      radioColor: PetTokens.clayText,
                      onTap: () => _onSelect(ReportType.lost),
                    ),
                    const SizedBox(height: 16),

                    // Opción B: Encontré una mascota
                    _OptionCard(
                      isSelected: _selectedType == ReportType.found,
                      borderColor: PetTokens.mint,
                      selectedBg: PetTokens.isDark(context)
                          ? const Color(0xFF1B312A)
                          : const Color(0xFFE8F3EF),
                      artWidget: const _BeatingHeartPetArt(),
                      title: l10n.reportFoundTitle,
                      subtitle: l10n.reportFoundDescription,
                      radioColor: PetTokens.mint,
                      onTap: () => _onSelect(ReportType.found),
                    ),
                  ],
                ),
              ),
            ),

            // Botón inferior flotante
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter,
                0,
                PetTokens.gutter,
                24,
              ),
              child: InkWell(
                onTap: hasSelection
                    ? () => context.push('/report/new/pet-info')
                    : null,
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: PetTokens.dFast,
                  height: 56,
                  decoration: BoxDecoration(
                    color: hasSelection ? PetTokens.plum : const Color(0xFFE6DCD3),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: hasSelection ? PetTokens.shadowButton : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasSelection
                            ? l10n.continueAction
                            : l10n.continueAction,
                        style: PetTokens.body(
                          16,
                          color: hasSelection ? Colors.white : PetTokens.placeholder,
                          weight: FontWeight.w700,
                        ),
                      ),
                      if (hasSelection) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TARJETA DE OPCIÓN (Perdí / Encontré)
// -----------------------------------------------------------------------------
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.isSelected,
    required this.borderColor,
    required this.selectedBg,
    required this.artWidget,
    required this.title,
    required this.subtitle,
    required this.radioColor,
    required this.onTap,
  });

  final bool isSelected;
  final Color borderColor;
  final Color selectedBg;
  final Widget artWidget;
  final String title;
  final String subtitle;
  final Color radioColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: PetTokens.dFast,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : PetTokens.surfaceOf(context),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? borderColor : PetTokens.borderOf(context),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.16),
                    offset: const Offset(0, 14),
                    blurRadius: 30,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x082A1A29),
                    offset: Offset(0, 4),
                    blurRadius: 14,
                  ),
                ],
        ),
        child: Row(
          children: [
            artWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PetTokens.displayThemed(context, 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? radioColor : const Color(0xFFCDBFB4),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: radioColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ARTE CON CORREA OSCILANTE (Paso1Tipo)
// -----------------------------------------------------------------------------
class _SwingingLeashArt extends StatefulWidget {
  const _SwingingLeashArt();

  @override
  State<_SwingingLeashArt> createState() => _SwingingLeashArtState();
}

class _SwingingLeashArtState extends State<_SwingingLeashArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFFBE3DA),
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = math.sin(_controller.value * math.pi) * 0.22;
          return Transform.rotate(
            angle: angle,
            alignment: const Alignment(0, -0.7),
            child: child,
          );
        },
        child: CustomPaint(
          size: const Size(40, 56),
          painter: _LeashPainter(),
        ),
      ),
    );
  }
}

class _LeashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strapPaint = Paint()
      ..color = PetTokens.plum
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final collarPaint = Paint()
      ..color = PetTokens.clayText
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final tagPaint = Paint()
      ..color = PetTokens.tagGold
      ..style = PaintingStyle.fill;

    // Cinta
    canvas.drawLine(const Offset(20, 4), const Offset(20, 32), strapPaint);
    // Collar
    canvas.drawCircle(const Offset(20, 40), 10, collarPaint);
    // Placa dorada
    canvas.drawCircle(const Offset(20, 50), 3.5, tagPaint);
    // Anillo superior
    canvas.drawCircle(const Offset(20, 4), 3, Paint()..color = PetTokens.plum);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// ARTE CON CORAZÓN LATIENDO Y PERRITO (Paso1Tipo)
// -----------------------------------------------------------------------------
class _BeatingHeartPetArt extends StatefulWidget {
  const _BeatingHeartPetArt();

  @override
  State<_BeatingHeartPetArt> createState() => _BeatingHeartPetArtState();
}

class _BeatingHeartPetArtState extends State<_BeatingHeartPetArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFE9),
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Perrito vector
          CustomPaint(
            size: const Size(44, 44),
            painter: _PetFacePainter(),
          ),

          // Corazón latiendo en la esquina superior derecha
          Positioned(
            right: 8,
            top: 8,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = 1.0 + 0.25 * math.sin(_controller.value * math.pi);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const Icon(
                Icons.favorite_rounded,
                color: PetTokens.mint,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final headPaint = Paint()..color = PetTokens.dogTan;
    final earPaint = Paint()
      ..color = PetTokens.dogEar
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final featurePaint = Paint()..color = PetTokens.ink;

    final center = Offset(size.width / 2, size.height / 2);

    // Orejas
    canvas.drawLine(Offset(center.dx - 12, center.dy - 12), Offset(center.dx - 16, center.dy + 4), earPaint);
    canvas.drawLine(Offset(center.dx + 12, center.dy - 12), Offset(center.dx + 16, center.dy + 4), earPaint);

    // Cabeza
    canvas.drawCircle(center, 15, headPaint);

    // Hocico
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 5), width: 14, height: 10),
      Paint()..color = PetTokens.dogMuzzle,
    );

    // Ojos y nariz
    canvas.drawCircle(Offset(center.dx - 5, center.dy - 2), 2, featurePaint);
    canvas.drawCircle(Offset(center.dx + 5, center.dy - 2), 2, featurePaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), 2.5, featurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
