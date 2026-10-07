import 'package:flutter/material.dart';

import '../../core/theme/pet_radius.dart';
import '../../design_system/badges/status_badge.dart';
import '../models/pet_report.dart';

class PetCardCompact extends StatelessWidget {
  final PetReport report;
  final VoidCallback? onTap;

  const PetCardCompact({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: PetRadius.lgAll,
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: PetRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: PetRadius.mdAll,
                ),
                child: Icon(
                  report.pet.species == 'Gato' ? Icons.pets : Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                        StatusBadge(status: _reportTypeToStatus(report.type)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${report.pet.breed} · ${report.pet.sex}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${report.distanceKm} km · ${report.address.split(',').first}',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  PetStatus _reportTypeToStatus(ReportType type) {
    switch (type) {
      case ReportType.lost:
        return PetStatus.lost;
      case ReportType.found:
        return PetStatus.found;
    }
  }
}
