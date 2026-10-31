import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_tokens.dart';
import '../../shared/models/activity_item.dart';
import '../../shared/widgets/pet_paw_painters.dart';
import 'providers/activity_providers.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activityAsync = ref.watch(activityProvider);
    final unreadCount = ref.watch(unreadActivityCountProvider);

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: PetTokens.plum,
          backgroundColor: PetTokens.surfaceOf(context),
          onRefresh: () => ref.read(activityProvider.notifier).refresh(),
          child: activityAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: PetTokens.plum),
            ),
            error: (error, _) => _buildErrorState(context, ref, l10n),
            data: (items) {
              return SingleChildScrollView(
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
                    // Header segun Actividad.dc.html
                    _buildHeader(context, ref, unreadCount, l10n),
                    const SizedBox(height: 24),

                    if (items.isEmpty)
                      const _EmptyActivityState()
                    else
                      _buildTimelineList(context, ref, items, l10n),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    int unreadCount,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.navigationActivity.toUpperCase(),
                style: PetTokens.body(
                  12,
                  color: PetTokens.muted,
                  weight: FontWeight.w700,
                  letterSpacing: 0.14,
                ),
              ),
              if (unreadCount > 0)
                InkWell(
                  onTap: () =>
                      ref.read(activityProvider.notifier).markAllAsRead(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: PetTokens.lostTextOf(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.activityMarkAllAsRead,
                          style: PetTokens.body(
                            12,
                            color: PetTokens.lostTextOf(context),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.activityRecent,
            style: PetTokens.displayThemed(context, 34),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.activityDescription,
            style: PetTokens.bodyThemed(context, 15, color: PetTokens.mutedOf(context)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TIMELINE
  // ---------------------------------------------------------------------------
  Widget _buildTimelineList(
    BuildContext context,
    WidgetRef ref,
    List<ActivityItem> items,
    AppLocalizations l10n,
  ) {
    // Agrupar items por fecha relativa
    final grouped = <String, List<ActivityItem>>{};
    for (final item in items) {
      final key = _groupDateLabel(context, item.createdAt);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PetTokens.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 12),
              child: Text(
                entry.key.toUpperCase(),
                style: PetTokens.bodyThemed(
                  context,
                  12,
                  color: PetTokens.mutedOf(context),
                  weight: FontWeight.w800,
                  letterSpacing: 0.14,
                ),
              ),
            ),
            _TimelineGroup(
              items: entry.value,
              onTapItem: (item) {
                if (!item.isRead) {
                  ref.read(activityProvider.notifier).markAsRead(item.id);
                }
                context.push('/reports/${item.targetReportId}');
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  String _groupDateLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (diff.inDays == 0) {
      return l10n.timeToday;
    } else if (diff.inDays == 1) {
      return l10n.timeYesterday;
    } else if (diff.inDays < 7) {
      return l10n.timeDaysAgoFull(diff.inDays);
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return l10n.timeWeeksAgo(weeks);
    } else {
      final months = (diff.inDays / 30).floor();
      return l10n.timeMonthsAgo(months);
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------
  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: PetTokens.clay,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.activityError,
              style: PetTokens.displayThemed(context, 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: PetTokens.plum,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => ref.read(activityProvider.notifier).refresh(),
              child: Text(
                l10n.activityRetry,
                style: PetTokens.body(14, color: PetTokens.cream, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// GRUPO TIMELINE CON LÍNEA VERTICAL CONECTORA
// -----------------------------------------------------------------------------
class _TimelineGroup extends StatelessWidget {
  const _TimelineGroup({required this.items, required this.onTapItem});

  final List<ActivityItem> items;
  final ValueChanged<ActivityItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Línea vertical discontinua conectora
        Positioned(
          left: 21,
          top: 22,
          bottom: 22,
          child: CustomPaint(
            size: const Size(2, double.infinity),
            painter: _DashedLinePainter(
              color: PetTokens.isDark(context)
                  ? PetTokens.borderOf(context)
                  : PetTokens.borderDark,
            ),
          ),
        ),

        // Lista de items con su nodo correspondiente
        Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _TimelineRow(item: items[i], onTap: () => onTapItem(items[i])),
              if (i < items.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.onTap});

  final ActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final l10n = AppLocalizations.of(context)!;

    // Configuración del nodo según el tipo de actividad en Actividad.dc.html
    final isDark = PetTokens.isDark(context);
    final (Color dotBg, Color dotColor, Widget icon) = switch (item.type) {
      'sighting' => (
        PetTokens.clay,
        Colors.white,
        const Icon(PhosphorIconsBold.binoculars, size: 20, color: Colors.white),
      ),
      'report' => (
        isDark ? const Color(0xFF382338) : const Color(0xFFEFE3EC),
        PetTokens.plumAccentOf(context),
        PetPaw(size: 18, color: PetTokens.plumAccentOf(context)),
      ),
      'match' => (
        PetTokens.mint,
        Colors.white,
        const Icon(PhosphorIconsBold.sparkle, size: 20, color: Colors.white),
      ),
      _ => (
        PetTokens.plum,
        Colors.white,
        const Icon(PhosphorIconsBold.bell, size: 20, color: Colors.white),
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nodo squircle de la línea de tiempo (44x44, radius 15)
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: dotBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: PetTokens.bgOf(context), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x142A1A29),
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: icon,
        ),
        const SizedBox(width: 10),

        // Tarjeta de la actividad
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: PetTokens.dNormal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: PetTokens.surfaceOf(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isUnread
                      ? (isDark ? const Color(0xFF8A3B28) : const Color(0xFFE9B6A5))
                      : PetTokens.borderOf(context),
                  width: isUnread ? 1.5 : 1.0,
                ),
                boxShadow: [
                  if (isUnread)
                    BoxShadow(
                      color: isDark
                          ? const Color(0x33E07A5F)
                          : const Color(0x1FE07A5F),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    )
                  else
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0x0A2A1A29),
                      offset: const Offset(0, 3),
                      blurRadius: 10,
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y tiempo relativo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: _buildItemTitle(context, item.title),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatShortTime(item.createdAt),
                        style: PetTokens.bodyThemed(
                          context,
                          12,
                          color: PetTokens.mutedOf(context),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Cuerpo descriptivo
                  if (item.body != null && item.body!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.body!,
                      style: PetTokens.bodyThemed(context, 14, color: PetTokens.mutedOf(context)),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Badges de estado (Nuevo / Activo / etc.)
                  Row(
                    children: [
                      if (isUnread) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PetTokens.lostBgOf(context),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _PulsingClayDot(),
                              const SizedBox(width: 5),
                              Text(
                                l10n.statusNew,
                                style: PetTokens.body(
                                  11,
                                  color: PetTokens.lostTextOf(context),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (item.status == 'active')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PetTokens.mintBgOf(context),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            l10n.activityStatusActive,
                            style: PetTokens.body(
                              11,
                              color: PetTokens.mintTextOf(context),
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTitle(BuildContext context, String title) {
    // Si contiene "de [Nombre]", resaltar el nombre con tipografía Fraunces itálica
    final match = RegExp(r'^(.*?\bde\s+)([A-ZÁÉÍÓÚÑa-záéíóúñ]+)(.*)$').firstMatch(title);
    if (match != null) {
      return Text.rich(
        TextSpan(
          style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
          children: [
            TextSpan(text: match.group(1)),
            TextSpan(
              text: match.group(2),
              style: PetTokens.displayThemed(
                context,
                16,
                color: PetTokens.inkOf(context),
                italic: true,
              ),
            ),
            TextSpan(text: match.group(3)),
          ],
        ),
      );
    }

    return Text(
      title,
      style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
    );
  }

  String _formatShortTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)} m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} h';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} d';
    } else {
      return '${(diff.inDays / 30).floor()} m';
    }
  }
}

// -----------------------------------------------------------------------------
// PIN DOTTED LINE PAINTER
// -----------------------------------------------------------------------------
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 5.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// -----------------------------------------------------------------------------
// PUNTO CLAY PULSANTE
// -----------------------------------------------------------------------------
class _PulsingClayDot extends StatefulWidget {
  const _PulsingClayDot();

  @override
  State<_PulsingClayDot> createState() => _PulsingClayDotState();
}

class _PulsingClayDotState extends State<_PulsingClayDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final scale = 0.8 + 1.2 * t;
          final opacity = (1.0 - t).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: PetTokens.clay.withValues(alpha: opacity * 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: PetTokens.clay,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EMPTY STATE DE ACTIVIDAD
// -----------------------------------------------------------------------------
class _EmptyActivityState extends StatefulWidget {
  const _EmptyActivityState();

  @override
  State<_EmptyActivityState> createState() => _EmptyActivityStateState();
}

class _EmptyActivityStateState extends State<_EmptyActivityState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = math.sin(_controller.value * math.pi) * 0.12;
              return Transform.rotate(
                angle: angle,
                alignment: const Alignment(0, 0.9),
                child: child,
              );
            },
            child: PetPaw(size: 64, color: PetTokens.trackOf(context)),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.activityEmpty,
            style: PetTokens.displayThemed(context, 20),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.activityDescription,
            style: PetTokens.bodyThemed(context, 14, color: PetTokens.mutedOf(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
