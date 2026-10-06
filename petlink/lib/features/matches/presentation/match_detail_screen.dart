import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_match.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/matches_providers.dart';

class MatchDetailScreen extends ConsumerWidget {
  final String matchId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchByIdProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posible coincidencia'),
      ),
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return _buildNotFound(context);
          }

          return _buildMatchDetail(context, match);
        },
        loading: () => _buildLoading(context),
        error: (Object _, StackTrace _) => ErrorState(
          title: 'No pudimos cargar la coincidencia',
          subtitle: 'Verifica tu conexión e intenta nuevamente.',
          onRetry: () => ref.invalidate(matchByIdProvider(matchId)),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return const EmptyState(
      icon: Icons.diamond,
      title: 'Esta coincidencia ya no está disponible.',
      subtitle: 'Puede haber sido descartada o eliminada.',
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(PetSpacing.lg),
      children: [
        _buildSkeletonCard(),
        const SizedBox(height: PetSpacing.lg),
        _buildSkeletonCard(),
        const SizedBox(height: PetSpacing.lg),
        _buildSkeletonCard(),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: PetColors.border,
        borderRadius: PetRadius.lgAll,
      ),
    );
  }

  Widget _buildMatchDetail(
    BuildContext context,
    PetMatch match,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PetSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(context, match),
          const SizedBox(height: PetSpacing.lg),
          _buildComparisonSection(context, match),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: 'Comparación de características',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildTraitsComparison(context, match),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: 'Ubicación y momento',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildLocationTimeSection(context, match),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: 'Rasgos particulares',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildParticularTraitsSection(context, match),
          const SizedBox(height: PetSpacing.xl),
          _buildCTASection(context),
          const SizedBox(height: PetSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    PetMatch match,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: PetColors.matchSoft,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: PetColors.match.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                status: PetStatus.match,
              ),
              const SizedBox(width: PetSpacing.md),
              Expanded(
                child: Text(
                  'Coincidencia alta',
                  style: (
                    Theme.of(context).textTheme.titleMedium ??
                        const TextStyle()
                  ).copyWith(
                    color: PetColors.match,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.md),
          Text(
            'Las características, la ubicación y el momento de ambos '
            'reportes son similares. Revisa la información antes de contactar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    BuildContext context,
    PetMatch match,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildReportCard(
            context,
            match.lostReport,
            match,
            true,
          ),
        ),
        const SizedBox(width: PetSpacing.md),
        Expanded(
          child: _buildReportCard(
            context,
            match.foundReport,
            match,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    dynamic report,
    PetMatch match,
    bool isLost,
  ) {
    final isFound = !isLost;
    final badgeStatus = isLost ? PetStatus.lost : PetStatus.found;
    final title = isLost ? 'Tu reporte' : 'Mascota encontrada';
    final subtitle = report.address.split(',').first;

    return Container(
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: PetColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.pet.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                status: badgeStatus,
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: PetSpacing.xs),
          if (isFound) ...[
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 14,
                  color: PetColors.textSecondary,
                ),
                const SizedBox(width: PetSpacing.xs),
                Text(
                  '${match.distanceKm} km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: PetSpacing.xs),
          ],
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: PetColors.textSecondary,
              ),
              const SizedBox(width: PetSpacing.xs),
              Text(
                isLost ? 'Hace 5 h' : 'Hace 3 h',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsComparison(
    BuildContext context,
    PetMatch match,
  ) {
    final comparisons = [
      ('Especie', 'Perro', 'Perro'),
      ('Raza', 'Golden Retriever', 'Golden Retriever'),
      ('Color', 'Dorado', 'Dorado'),
      ('Tamaño', 'Grande', 'Grande'),
      ('Sexo', 'Hembra', 'Hembra'),
    ];

    return Column(
      children: comparisons.map((comp) {
        return Container(
          margin: const EdgeInsets.only(
            bottom: PetSpacing.md,
          ),
          padding: const EdgeInsets.all(
            PetSpacing.md,
          ),
          decoration: BoxDecoration(
            color: PetColors.surface,
            borderRadius: PetRadius.lgAll,
            border: Border.all(
              color: PetColors.border,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  comp.$1,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PetColors.textSecondary,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  comp.$2,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetSpacing.sm,
                  vertical: PetSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: PetColors.foundSoft,
                  borderRadius: PetRadius.smAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 14,
                      color: PetColors.found,
                    ),
                    const SizedBox(width: PetSpacing.xs),
                    const Text(
                      'Coincide',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PetColors.found,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PetSpacing.md),
              Expanded(
                child: Text(
                  comp.$3,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationTimeSection(
    BuildContext context,
    PetMatch match,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: PetColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 28,
                  color: PetColors.primary,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  'Distancia entre reportes',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  '${match.distanceKm} km',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: PetColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: PetColors.border,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 28,
                  color: PetColors.primary,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  'Tiempo entre reportes',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  _formatDuration(
                    match.timeDifference,
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        color: PetColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} horas';
    }

    return '${duration.inMinutes} minutos';
  }

  Widget _buildParticularTraitsSection(
    BuildContext context,
    PetMatch match,
  ) {
    final lostTraits = [
      'Color: Dorado suave',
      'Collar: Cuero marrón con hebilla dorada',
      'Seña física: Mancha blanca en el pecho',
      'Temperamento: Dócil, responde a su nombre',
    ];

    final foundTraits = [
      'Color: Dorado',
      'Collar: Sin collar visible',
      'Seña física: Mancha blanca en el pecho',
      'Temperamento: Tranquila, se deja acercar',
    ];

    return Column(
      children: List.generate(
        lostTraits.length,
        (index) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: PetSpacing.md,
            ),
            padding: const EdgeInsets.all(
              PetSpacing.md,
            ),
            decoration: BoxDecoration(
              color: PetColors.surface,
              borderRadius: PetRadius.lgAll,
              border: Border.all(
                color: PetColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PetSpacing.sm,
                        vertical: PetSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: PetColors.lostSoft,
                        borderRadius: PetRadius.smAll,
                      ),
                      child: const Text(
                        'Perdida',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PetColors.lost,
                        ),
                      ),
                    ),
                    const SizedBox(width: PetSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PetSpacing.sm,
                        vertical: PetSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: PetColors.foundSoft,
                        borderRadius: PetRadius.smAll,
                      ),
                      child: const Text(
                        'Encontrada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: PetColors.found,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PetSpacing.md),
                Text(
                  lostTraits[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: PetSpacing.sm),
                Text(
                  foundTraits[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PetButton(
          label: 'Contactar a quien la encontró',
          onPressed: () {},
          icon: Icons.phone,
        ),
        const SizedBox(height: PetSpacing.md),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: PetSpacing.md,
            ),
            foregroundColor: PetColors.lost,
            side: const BorderSide(
              color: PetColors.lost,
              width: 1.5,
            ),
          ),
          child: const Text(
            'Descartar coincidencia',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: PetButton(
          label: 'Volver',
          onPressed: () => Navigator.of(context).pop(),
          variant: PetButtonVariant.outline,
        ),
      ),
    );
  }
}