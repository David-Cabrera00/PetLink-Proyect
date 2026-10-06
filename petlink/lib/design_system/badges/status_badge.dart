import 'package:flutter/material.dart';
import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';

enum PetStatus { lost, found, match, recovered }

class StatusBadge extends StatelessWidget {
  final PetStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _statusData;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PetSpacing.md,
        vertical: PetSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: PetRadius.smAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: PetSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) get _statusData {
    switch (status) {
      case PetStatus.lost:
        return ('Perdida', PetColors.lost, Icons.priority_high);
      case PetStatus.found:
        return ('Encontrada', PetColors.found, Icons.check_circle);
      case PetStatus.match:
        return ('Posible coincidencia', PetColors.match, Icons.diamond);
      case PetStatus.recovered:
        return ('Recuperada', PetColors.found, Icons.favorite);
    }
  }
}
