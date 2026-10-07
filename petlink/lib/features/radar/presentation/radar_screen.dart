import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/widgets/match_card.dart';
import '../../../shared/widgets/pet_card_compact.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../providers/radar_providers.dart';

class RadarScreen extends ConsumerWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyReportsProvider);
    final matchesAsync = ref.watch(matchesProvider);
    final summary = ref.watch(radarSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Radar')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nearbyReportsProvider);
          ref.invalidate(matchesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(PetSpacing.lg),
          children: [
            _buildHeader(context),
            const SizedBox(height: PetSpacing.xl),
            _buildZoneSelector(context),
            const SizedBox(height: PetSpacing.xl),
            _buildRadarActiveSection(context, summary),
            const SizedBox(height: PetSpacing.xl),
            _buildMatchesSection(context, matchesAsync, ref),
            const SizedBox(height: PetSpacing.xl),
            _buildNearbySection(context, nearbyAsync, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buenos días, David',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          'Esto está ocurriendo cerca de ti.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildZoneSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PetColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PetSpacing.md),
            decoration: BoxDecoration(
              color: PetColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on, color: PetColors.primary),
          ),
          const SizedBox(width: PetSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La Aurora, Pasto',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  'Radio 5 km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: PetColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildRadarActiveSection(BuildContext context, RadarSummary summary) {
    return Column(
      children: [
        SectionHeader(
          title: 'Radar activo',
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PetSpacing.md,
              vertical: PetSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: PetColors.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '${summary.totalReports} reportes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PetColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: PetSpacing.md),
        Container(
          padding: const EdgeInsets.all(PetSpacing.lg),
          decoration: BoxDecoration(
            color: PetColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PetColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.pets, color: PetColors.primary, size: 24),
                  const SizedBox(width: PetSpacing.md),
                  Expanded(
                    child: Text(
                      '${summary.totalReports} reportes en un radio de 5 km',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.md),
              Row(
                children: [
                  Icon(Icons.access_time, color: PetColors.accent, size: 24),
                  const SizedBox(width: PetSpacing.md),
                  Expanded(
                    child: Text(
                      '${summary.recentReports} publicados en las últimas 24 h',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.lg),
              PetButton(
                label: 'Explorar el radar',
                onPressed: () {},
                icon: Icons.explore,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesSection(
    BuildContext context,
    AsyncValue matchesAsync,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        SectionHeader(title: 'Posibles coincidencias'),
        const SizedBox(height: PetSpacing.md),
        matchesAsync.when(
          data: (matches) {
            if (matches.isEmpty) {
              return _buildEmptyMatches(context);
            }
            return Column(
              children: matches
                  .map<Widget>(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: PetSpacing.md),
                      child: MatchCard(
                        match: match,
                        onTap: () => context.go('/matches/${match.id}'),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (Object _, StackTrace _) => ErrorState(
            title: 'No pudimos cargar las coincidencias',
            subtitle: 'Verifica tu conexión e intenta nuevamente.',
            onRetry: () => ref.invalidate(matchesProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMatches(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PetSpacing.xl),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PetColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: PetColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: PetSpacing.md),
          Text(
            'Sin coincidencias todavía',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            'Seguimos comparando tu reporte con mascotas encontradas cerca de ti.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection(
    BuildContext context,
    AsyncValue nearbyAsync,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        SectionHeader(title: 'Cerca de ti'),
        const SizedBox(height: PetSpacing.md),
        nearbyAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return EmptyState(
                icon: Icons.location_off,
                title: 'No hay reportes cerca',
                subtitle: 'Los reportes de mascotas aparecerán aquí cuando estén cerca de tu ubicación.',
              );
            }
            return Column(
              children: reports
                  .take(3)
                  .map<Widget>(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: PetSpacing.md),
                      child: PetCardCompact(
                        report: report,
                        onTap: () => context.go('/reports/${report.id}'),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (Object _, StackTrace _) => ErrorState(
            title: 'No pudimos cargar los reportes',
            subtitle: 'Verifica tu conexión e intenta nuevamente.',
            onRetry: () => ref.invalidate(nearbyReportsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PetColors.border),
      ),
      child: Center(child: CircularProgressIndicator(color: PetColors.primary)),
    );
  }
}
