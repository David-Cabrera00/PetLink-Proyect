import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_match.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/matches_providers.dart';

class MatchDetailScreen extends ConsumerWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final matchAsync = ref.watch(matchByIdProvider(matchId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchDetailTitle)),
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return _buildNotFound(context);
          }
          return _buildMatchDetail(context, match);
        },
        loading: () => _buildLoading(context),
        error: (Object _, StackTrace _) => ErrorState(
          title: l10n.matchDetailLoadError,
          subtitle: l10n.connectionRetryDescription,
          onRetry: () => ref.invalidate(matchByIdProvider(matchId)),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.diamond,
      title: l10n.matchDetailNotFound,
      subtitle: l10n.matchDetailNotFoundDescription,
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

  Widget _buildMatchDetail(BuildContext context, PetMatch match) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PetSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context, match),
              const SizedBox(height: PetSpacing.lg),
              _buildComparisonSection(context, match, isNarrow),
              const SizedBox(height: PetSpacing.lg),
              SectionHeader(title: l10n.matchDetailComparison),
              const SizedBox(height: PetSpacing.md),
              _buildTraitsComparison(context, match, isNarrow),
              const SizedBox(height: PetSpacing.lg),
              SectionHeader(title: l10n.matchDetailLocationTime),
              const SizedBox(height: PetSpacing.md),
              _buildLocationTimeSection(context, match, isNarrow),
              const SizedBox(height: PetSpacing.lg),
              SectionHeader(title: l10n.matchDetailTraits),
              const SizedBox(height: PetSpacing.md),
              _buildParticularTraitsSection(context, match),
              const SizedBox(height: PetSpacing.xl),
              _buildCTASection(context),
              const SizedBox(height: PetSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, PetMatch match) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: PetColors.matchSoft,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: PetColors.match.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(status: PetStatus.match),
              const SizedBox(width: PetSpacing.md),
              Expanded(
                child: Text(
                  l10n.matchDetailHigh,
                  style:
                      (Theme.of(context).textTheme.titleMedium ??
                              const TextStyle())
                          .copyWith(
                            color: PetColors.match,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.md),
          Text(
            l10n.matchDetailDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    BuildContext context,
    PetMatch match,
    bool isNarrow,
  ) {
    if (isNarrow) {
      return Column(
        children: [
          _buildReportCard(context, match.lostReport, match, true),
          const SizedBox(height: PetSpacing.md),
          _buildReportCard(context, match.foundReport, match, false),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _buildReportCard(context, match.lostReport, match, true),
        ),
        const SizedBox(width: PetSpacing.md),
        Expanded(
          child: _buildReportCard(context, match.foundReport, match, false),
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
    final badgeStatus = isLost ? PetStatus.lost : PetStatus.found;
    final l10n = AppLocalizations.of(context)!;
    final title = isLost
        ? l10n.matchDetailYourReport
        : l10n.matchDetailFoundPet;
    final subtitle = report.address.split(',').first;

    return Container(
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: PetColors.border),
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
              StatusBadge(status: badgeStatus),
            ],
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: PetSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: PetSpacing.xs),
          if (!isLost) ...[
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
                isLost ? l10n.timeHoursAgo(5) : l10n.timeHoursAgo(3),
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
    bool isNarrow,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final comparisons = [
      (l10n.matchDetailSpecies, l10n.matchValueDog, l10n.matchValueDog),
      (
        l10n.matchDetailBreed,
        l10n.matchValueGoldenRetriever,
        l10n.matchValueGoldenRetriever,
      ),
      (l10n.matchDetailColor, l10n.matchValueGold, l10n.matchValueGold),
      (l10n.matchDetailSize, l10n.matchValueLarge, l10n.matchValueLarge),
      (l10n.matchDetailSex, l10n.matchValueFemale, l10n.matchValueFemale),
    ];

    return Column(
      children: comparisons.map((comp) {
        return Container(
          margin: const EdgeInsets.only(bottom: PetSpacing.md),
          padding: const EdgeInsets.all(PetSpacing.md),
          decoration: BoxDecoration(
            color: PetColors.surface,
            borderRadius: PetRadius.lgAll,
            border: Border.all(color: PetColors.border),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comp.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PetColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PetSpacing.sm),
                    Row(
                      children: [
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
                              Text(
                                l10n.matchDetailMatches,
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
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        comp.$1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          Text(
                            l10n.matchDetailMatches,
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
    bool isNarrow,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: PetColors.border),
      ),
      child: isNarrow
          ? Column(
              children: [
                _buildLocationTimeItem(
                  context,
                  Icons.straighten,
                  l10n.matchDetailDistance,
                  '${match.distanceKm} km',
                ),
                const SizedBox(height: PetSpacing.md),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: PetColors.border,
                ),
                const SizedBox(height: PetSpacing.md),
                _buildLocationTimeItem(
                  context,
                  Icons.access_time,
                  l10n.matchDetailTimeBetween,
                  _formatDuration(l10n, match.timeDifference),
                ),
              ],
            )
          : Row(
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
                        l10n.matchDetailDistance,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Text(
                        '${match.distanceKm} km',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: PetColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: PetColors.border),
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
                        l10n.matchDetailTimeBetween,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Text(
                        _formatDuration(l10n, match.timeDifference),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildLocationTimeItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: PetColors.primary),
        const SizedBox(height: PetSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: PetColors.primary, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    if (duration.inHours > 0) {
      return l10n.timeHoursAgo(duration.inHours);
    }
    return l10n.timeMinutesAgo(duration.inMinutes);
  }

  Widget _buildParticularTraitsSection(BuildContext context, PetMatch match) {
    final l10n = AppLocalizations.of(context)!;
    final lostTraits = [
      '${l10n.reportDetailColor}: ${l10n.reportDetailSoftGold}',
      '${l10n.reportDetailCollar}: ${l10n.reportDetailBrownCollar}',
      '${l10n.reportDetailPhysicalMark}: ${l10n.reportDetailWhiteMark}',
      '${l10n.reportDetailTemperament}: ${l10n.reportDetailDocile}',
    ];
    final foundTraits = [
      '${l10n.reportDetailColor}: ${l10n.matchValueGold}',
      '${l10n.reportDetailCollar}: ${l10n.matchValueNoVisibleCollar}',
      '${l10n.reportDetailPhysicalMark}: ${l10n.reportDetailWhiteMark}',
      '${l10n.reportDetailTemperament}: ${l10n.matchValueCalm}',
    ];

    return Column(
      children: List.generate(lostTraits.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: PetSpacing.md),
          padding: const EdgeInsets.all(PetSpacing.md),
          decoration: BoxDecoration(
            color: PetColors.surface,
            borderRadius: PetRadius.lgAll,
            border: Border.all(color: PetColors.border),
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
                    child: Text(
                      l10n.statusLost,
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
                    child: Text(
                      l10n.statusFound,
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
      }),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PetButton(
          label: l10n.matchDetailContactFinder,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.matchDetailContactFinder)),
            );
          },
          icon: Icons.phone,
        ),
        const SizedBox(height: PetSpacing.md),
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.matchDetailDismiss)),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
            foregroundColor: PetColors.lost,
            side: const BorderSide(color: PetColors.lost, width: 1.5),
          ),
          child: Text(l10n.matchDetailDismiss),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: PetButton(
          label: l10n.matchDetailBack,
          onPressed: () => Navigator.of(context).pop(),
          variant: PetButtonVariant.outline,
        ),
      ),
    );
  }
}
