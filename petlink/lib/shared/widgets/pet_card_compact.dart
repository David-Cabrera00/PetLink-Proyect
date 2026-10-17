import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_theme_extension.dart';
import '../../design_system/badges/status_badge.dart';
import '../models/pet_report.dart';

class PetCardCompact extends StatelessWidget {
  final PetReport report;
  final VoidCallback? onTap;

  const PetCardCompact({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extension = PetThemeExtension.of(context);
    final isLost = report.type == ReportType.lost;
    final statusColor = isLost ? extension.lost : extension.found;
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surface,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: PetRadius.lgAll,
        side: BorderSide(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: PetRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: PetRadius.lgAll,
                ),
                child: Icon(
                  report.pet.species == 'Gato'
                      ? PhosphorIconsRegular.cat
                      : PhosphorIconsRegular.dog,
                  color: statusColor,
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${report.distanceKm.toStringAsFixed(2).replaceAll('.', ',')} km · ${report.address.split(',').first}',
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
