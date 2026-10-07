import 'package:flutter/material.dart';

import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_theme_extension.dart';

enum PetStatus { lost, found, match, recovered }

class StatusBadge extends StatelessWidget {
  final PetStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final extension = PetThemeExtension.of(context);
    final (label, color, icon) = _statusData(extension);

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

  (String, Color, IconData) _statusData(PetThemeExtension extension) {
    switch (status) {
      case PetStatus.lost:
        return ('Perdida', extension.lost, Icons.priority_high);
      case PetStatus.found:
        return ('Encontrada', extension.found, Icons.check_circle);
      case PetStatus.match:
        return ('Posible coincidencia', extension.match, Icons.diamond);
      case PetStatus.recovered:
        return ('Recuperada', extension.found, Icons.favorite);
    }
  }
}
