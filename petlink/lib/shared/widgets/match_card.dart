import 'package:flutter/material.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';
import '../../design_system/badges/status_badge.dart';
import '../../core/theme/pet_theme_extension.dart';
import '../models/pet_match.dart';

class MatchCard extends StatelessWidget {
  final PetMatch match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: PetRadius.xlAll,
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: PetRadius.xlAll,
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${match.lostReport.pet.name} — ${l10n.matchCardYourReport}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          l10n.matchCardPetFound,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: _matchLevelToStatus(match.level)),
                ],
              ),
              const SizedBox(height: PetSpacing.md),
              Wrap(
                spacing: PetSpacing.sm,
                runSpacing: PetSpacing.xs,
                children: match.matchingTraits
                    .map((trait) => _buildTraitChip(context, trait))
                    .toList(),
              ),
              const SizedBox(height: PetSpacing.md),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: PetSpacing.xs),
                  Text(
                    '${match.distanceKm} km',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: PetSpacing.md),
                  Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: PetSpacing.xs),
                  Text(
                    _formatDuration(l10n, match.timeDifference),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraitChip(BuildContext context, String trait) {
    final extension = PetThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PetSpacing.sm,
        vertical: PetSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: extension.foundSoft,
        borderRadius: PetRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: extension.found),
          const SizedBox(width: PetSpacing.xs),
          Text(
            trait,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: extension.found,
            ),
          ),
        ],
      ),
    );
  }

  PetStatus _matchLevelToStatus(MatchLevel level) {
    switch (level) {
      case MatchLevel.high:
        return PetStatus.match;
      case MatchLevel.medium:
        return PetStatus.match;
      case MatchLevel.low:
        return PetStatus.match;
    }
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    if (duration.inHours > 0) {
      return l10n.timeHoursAgo(count: duration.inHours);
    }
    return l10n.timeMinutesAgo(count: duration.inMinutes);
  }
}
