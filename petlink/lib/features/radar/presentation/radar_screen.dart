import 'package:flutter/material.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final nearbyAsync = ref.watch(nearbyReportsProvider);
    final matchesAsync = ref.watch(matchesProvider);
    final summary = ref.watch(radarSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationRadar)),
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
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.radarGreeting('David'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PetSpacing.sm),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: PetSpacing.sm),
            Expanded(
              child: Text(
                l10n.radarNearYou,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: PetRadius.xlAll,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PetSpacing.md),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on, color: cs.primary),
          ),
          const SizedBox(width: PetSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.radarLocation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(
                  l10n.radarRadius,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildRadarActiveSection(BuildContext context, RadarSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        SectionHeader(
          title: l10n.radarActive,
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PetSpacing.md,
              vertical: PetSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              l10n.radarReportsCount(summary.totalReports),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: PetSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(vertical: PetSpacing.lg),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.totalReports}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: PetSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l10n.radarReportsWithinRadius(summary.totalReports),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                l10n.radarPublishedLast24Hours(summary.recentReports),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: PetSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: PetButton(
                  label: l10n.radarExplore,
                  onPressed: () => context.go('/explore'),
                  icon: Icons.arrow_forward,
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionHeader(title: l10n.radarPossibleMatches),
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
          loading: () => _buildLoadingCard(context),
          error: (Object _, StackTrace _) => ErrorState(
            title: l10n.radarMatchesLoadError,
            subtitle: l10n.connectionRetryDescription,
            onRetry: () => ref.invalidate(matchesProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMatches(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PetSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: PetSpacing.md),
          Text(
            l10n.radarNoMatches,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            l10n.radarNoMatchesDescription,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionHeader(title: l10n.radarNearby),
        const SizedBox(height: PetSpacing.md),
        nearbyAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return EmptyState(
                icon: Icons.location_off,
                title: l10n.radarNoNearbyReports,
                subtitle: l10n.radarNoNearbyReportsDescription,
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
          loading: () => _buildLoadingCard(context),
          error: (Object _, StackTrace _) => ErrorState(
            title: l10n.radarReportsLoadError,
            subtitle: l10n.connectionRetryDescription,
            onRetry: () => ref.invalidate(nearbyReportsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
