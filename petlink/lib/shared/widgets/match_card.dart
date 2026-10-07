import 'package:flutter/material.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';
import '../../design_system/badges/status_badge.dart';
import '../models/pet_match.dart';

class MatchCard extends StatelessWidget {
  final PetMatch match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
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
                          '${match.lostReport.pet.name} — Tu reporte',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          'Mascota encontrada',
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
                    .map((trait) => _buildTraitChip(trait))
                    .toList(),
              ),
              const SizedBox(height: PetSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: PetColors.textSecondary,
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Text(
                    '${match.distanceKm} km',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: PetSpacing.md),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: PetColors.textSecondary,
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Text(
                    _formatDuration(match.timeDifference),
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

  Widget _buildTraitChip(String trait) {
    return Container(
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
          Icon(Icons.check, size: 12, color: PetColors.found),
          const SizedBox(width: PetSpacing.xs),
          Text(
            trait,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: PetColors.found,
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

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return 'Hace ${duration.inHours} h';
    }
    return 'Hace ${duration.inMinutes} min';
  }
}
