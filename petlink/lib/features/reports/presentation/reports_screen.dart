import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../../explore/providers/explore_providers.dart';
import '../providers/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  final bool onlyMyReports;

  const ReportsScreen({super.key, this.onlyMyReports = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (onlyMyReports) {
      return _buildMyReportsScreen(context, ref, l10n);
    }

    return _buildHubScreen(context, ref, l10n);
  }

  // ---------------------------------------------------------------------------
  // HUB PRINCIPAL (Reportes.dc.html)
  // ---------------------------------------------------------------------------
  Widget _buildHubScreen(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            0,
            16,
            0,
            PetTokens.contentBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado según Reportes.dc.html
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter + 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.navigationReport.toUpperCase(),
                      style: PetTokens.bodyThemed(
                        context,
                        12,
                        color: PetTokens.mutedOf(context),
                        weight: FontWeight.w700,
                        letterSpacing: 0.14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.navigationReport,
                      style: PetTokens.displayThemed(context, 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contenido con las 3 tarjetas de Reportes.dc.html
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Tarjeta Grande Ciruela: Crear nuevo reporte
                    _CreateReportHeroCard(
                      onTap: () => context.push('/report/new'),
                    ),
                    const SizedBox(height: 14),

                    // 2. Tarjeta Mediana: Reportes de la comunidad
                    _CommunityReportsCard(
                      onTap: () {
                        ref.read(exploreViewModeProvider.notifier).state =
                            ExploreViewMode.list;
                        context.go('/explore');
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Fila punteada: Acceso a reportes personales en Perfil
                    _MyPersonalReportsLink(
                      onTap: () => context.push('/reports/mine'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA "MIS REPORTES" (desde Perfil o link personal)
  // ---------------------------------------------------------------------------
  Widget _buildMyReportsScreen(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final reportsAsync = ref.watch(myReportsProvider);
    final filter = ref.watch(reportsFilterProvider);

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con botón de regresar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.reportsTitle,
                      style: PetTokens.displayThemed(context, 24),
                    ),
                  ),
                ],
              ),
            ),

            // Chips de filtro (Todos / Activos / Recuperados)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter, vertical: 8),
              child: _buildFilterChips(context, ref, filter, l10n),
            ),
            const SizedBox(height: 6),

            // Lista de mis reportes
            Expanded(
              child: reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return _buildEmptyReportsState(context, l10n);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      PetTokens.gutter,
                      8,
                      PetTokens.gutter,
                      PetTokens.contentBottomPadding,
                    ),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MyReportItemCard(
                          report: report,
                          onTap: () => context.go('/reports/${report.id}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: PetTokens.plum),
                ),
                error: (err, st) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: PetTokens.clay,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.reportsLoadError,
                          style: PetTokens.display(16, color: PetTokens.ink),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: PetTokens.plum,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => ref.invalidate(myReportsProvider),
                          child: Text(
                            l10n.retryAction,
                            style: PetTokens.body(
                              14,
                              color: PetTokens.cream,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    ReportsFilter currentFilter,
    AppLocalizations l10n,
  ) {
    final filters = [
      (ReportsFilter.all, l10n.reportsFilterAll),
      (ReportsFilter.active, l10n.reportsFilterActive),
      (ReportsFilter.recovered, l10n.reportsFilterRecovered),
    ];

    return Row(
      children: [
        for (final (filter, label) in filters) ...[
          InkWell(
            onTap: () => ref.read(reportsFilterProvider.notifier).state = filter,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: PetTokens.dFast,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: currentFilter == filter
                    ? PetTokens.plum
                    : PetTokens.surfaceOf(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: currentFilter == filter
                      ? PetTokens.plum
                      : PetTokens.borderOf(context),
                ),
              ),
              child: Text(
                label,
                style: PetTokens.bodyThemed(
                  context,
                  13,
                  color: currentFilter == filter
                      ? PetTokens.cream
                      : PetTokens.mutedOf(context),
                  weight: currentFilter == filter
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildEmptyReportsState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetPaw(size: 64, color: PetTokens.trackOf(context)),
            const SizedBox(height: 16),
            Text(
              l10n.exploreNoReports,
              style: PetTokens.displayThemed(context, 20),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.exploreNoReportsDescription,
              style: PetTokens.bodyThemed(context, 14, color: PetTokens.mutedOf(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. TARJETA HERO: CREAR NUEVO REPORTE (Reportes.dc.html)
// -----------------------------------------------------------------------------
class _CreateReportHeroCard extends StatelessWidget {
  const _CreateReportHeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 236,
        decoration: BoxDecoration(
          color: PetTokens.plum,
          borderRadius: BorderRadius.circular(28),
          boxShadow: PetTokens.shadowButton,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Anillos decorativos y pulso terracota
              Positioned(
                right: -20,
                top: -10,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _HeroPulseRingsPainter(),
                ),
              ),

              // Pin flotante con huella animada
              const Positioned(
                right: 50,
                top: 40,
                child: _FloatingDropPin(),
              ),

              // Contenido inferior: Títulos y botón circular
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reportCreate,
                            style: PetTokens.display(
                              28,
                              color: PetTokens.cream,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.reportLostDescription,
                            style: PetTokens.body(
                              14,
                              color: const Color(0xFFD9C8D3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: PetTokens.cream,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: PetTokens.plum,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PIN FLOTANTE CON ANIMACIÓN SUAVE (float 4s)
// -----------------------------------------------------------------------------
class _FloatingDropPin extends StatefulWidget {
  const _FloatingDropPin();

  @override
  State<_FloatingDropPin> createState() => _FloatingDropPinState();
}

class _FloatingDropPinState extends State<_FloatingDropPin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
        final dy = math.sin(_controller.value * math.pi) * 8.0;
        return Transform.translate(
          offset: Offset(0, -dy),
          child: child,
        );
      },
      child: const PetMapPin(
        color: PetTokens.clay,
        width: 58,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. TARJETA REPORTES DE LA COMUNIDAD (Reportes.dc.html)
// -----------------------------------------------------------------------------
class _CommunityReportsCard extends StatelessWidget {
  const _CommunityReportsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 196,
        decoration: BoxDecoration(
          color: PetTokens.surfaceOf(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: PetTokens.borderOf(context)),
          boxShadow: PetTokens.shadowCard,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Ilustración superior de mapa con caminos y pines
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 96,
                child: CustomPaint(
                  painter: _CommunityMapBannerPainter(),
                ),
              ),

              // Contenido inferior: Título, descripción y botón
              Positioned(
                left: 22,
                right: 22,
                bottom: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.exploreMapTitle,
                            style: PetTokens.displayThemed(context, 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.exploreMapDescription,
                            style: PetTokens.bodyThemed(context, 14, color: PetTokens.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E8EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: PetTokens.plum,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. ENLACE PUNTEADO A REPORTES PERSONALES (Reportes.dc.html)
// -----------------------------------------------------------------------------
class _MyPersonalReportsLink extends StatelessWidget {
  const _MyPersonalReportsLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFD9CBC0),
          radius: 18,
          strokeWidth: 1.5,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsRegular.userCircle,
                size: 22,
                color: PetTokens.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: PetTokens.body(14, color: PetTokens.muted),
                    children: [
                      TextSpan(text: '${l10n.reportsTitle} \u00B7 '),
                      TextSpan(
                        text: l10n.navigationProfile,
                        style: PetTokens.body(
                          14,
                          color: PetTokens.plum,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: PetTokens.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TARJETA DE REPORTE PERSONAL (en _buildMyReportsScreen)
// -----------------------------------------------------------------------------
class _MyReportItemCard extends StatelessWidget {
  const _MyReportItemCard({required this.report, required this.onTap});

  final PetReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLost = report.type == ReportType.lost;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final badgeBg = isLost ? PetTokens.lostBg : PetTokens.mintBg;
    final badgeColor = isLost ? PetTokens.clayText : PetTokens.mintText;
    final statusText = isLost ? l10n.statusLost : l10n.statusFound;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PetTokens.surfaceOf(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PetTokens.borderOf(context)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C2A1A29),
              offset: Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar de la mascota con foto o huella
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 68,
                height: 68,
                color: isLost ? const Color(0xFFFCEEE8) : const Color(0xFFDDEFE9),
                child: (report.pet.primaryPhotoUrl != null &&
                        report.pet.primaryPhotoUrl!.isNotEmpty)
                    ? Image.network(
                        report.pet.primaryPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: PetPaw(
                            size: 28,
                            color: isLost ? PetTokens.clayText : PetTokens.mint,
                          ),
                        ),
                      )
                    : Center(
                        child: PetPaw(
                          size: 28,
                          color: isLost ? PetTokens.clayText : PetTokens.mint,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Información de la mascota
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.pet.name,
                          style: PetTokens.displayThemed(context, 18),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: PetTokens.body(
                            11,
                            color: badgeColor,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${report.pet.species} \u00B7 ${report.pet.sex}',
                    style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    report.address.isNotEmpty
                        ? report.address
                        : (isEn ? 'Recorded location' : 'Ubicaci\u00F3n registrada'),
                    style: PetTokens.bodyThemed(
                      context,
                      12,
                      color: PetTokens.mutedOf(context),
                      weight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PINTORES DE FONDO Y BORDES
// -----------------------------------------------------------------------------
class _HeroPulseRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.4);
    final ringPaint = Paint()
      ..color = const Color(0xFF5E3E5E)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 40, ringPaint);
    canvas.drawCircle(center, 80, ringPaint);
    canvas.drawCircle(center, 120, ringPaint);

    final pulsePaint = Paint()
      ..color = PetTokens.clay
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 30, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CommunityMapBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFEFE6DC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Calles blancas
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFCF8)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 40)
      ..lineTo(size.width, 40)
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.35, size.height)
      ..moveTo(size.width * 0.72, 0)
      ..lineTo(size.width * 0.72, size.height);
    canvas.drawPath(path, roadPaint);

    // Pines ilustrados de mascotas
    _drawMiniPin(canvas, Offset(size.width * 0.2, 40), PetTokens.clayText);
    _drawMiniPin(canvas, Offset(size.width * 0.52, 56), PetTokens.mint);
    _drawMiniPin(canvas, Offset(size.width * 0.82, 34), PetTokens.clayText);
  }

  void _drawMiniPin(Canvas canvas, Offset center, Color color) {
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 14, circlePaint);
    canvas.drawCircle(center, 14, strokePaint);

    canvas.save();
    canvas.translate(center.dx - 7, center.dy - 7);
    PawPainter(color: color).paint(canvas, const Size(14, 14));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    const dashLength = 6.0;
    const dashSpace = 5.0;

    double distance = 0;
    while (distance < metrics.length) {
      final extract = metrics.extractPath(distance, distance + dashLength);
      canvas.drawPath(extract, paint);
      distance += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
