import 'package:flutter/material.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_theme_extension.dart';
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PetSpacing.lg,
              PetSpacing.md,
              PetSpacing.lg,
              PetSpacing.xxl,
            ),
            children: [
              _buildHeader(context),
              const SizedBox(height: PetSpacing.lg),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final accent = PetThemeExtension.of(context).accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.pawPrint, color: cs.primary, size: 20),
            const SizedBox(width: PetSpacing.sm),
            Text(
              l10n.radarActive,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(height: PetSpacing.md),
        Text(
          l10n.radarGreeting('David'),
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          l10n.radarNearYou,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildZoneSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: PetRadius.xlAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(PetSpacing.sm),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: PetRadius.lgAll,
            ),
            child: Icon(PhosphorIconsRegular.mapPin, color: cs.primary),
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
          Icon(PhosphorIconsRegular.caretRight, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildRadarActiveSection(BuildContext context, RadarSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: PetRadius.xxlAll,
        border: Border.all(color: cs.onPrimary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.radar,
                          size: 18,
                          color: cs.onPrimary,
                        ),
                        const SizedBox(width: PetSpacing.sm),
                        Text(
                          l10n.radarActive.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: cs.onPrimary.withValues(alpha: 0.78),
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PetSpacing.md),
                    Text(
                      l10n.radarReportsWithinRadius(summary.totalReports),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: PetSpacing.sm),
                    Text(
                      l10n.radarPublishedLast24Hours(summary.recentReports),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PetSpacing.md),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.onPrimary.withValues(alpha: 0.24),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${summary.totalReports}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/explore'),
              icon: const Icon(PhosphorIconsRegular.arrowRight),
              label: Text(l10n.radarExplore),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: cs.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: PetRadius.lgAll,
                ),
              ),
            ),
          ),
        ],
      ),
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
            PhosphorIconsRegular.magnifyingGlass,
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
                icon: PhosphorIconsRegular.mapPinLine,
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
