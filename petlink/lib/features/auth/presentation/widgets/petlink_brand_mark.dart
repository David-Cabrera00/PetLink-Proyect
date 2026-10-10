import 'package:flutter/material.dart';

import '../../../../core/theme/pet_typography.dart';

class PetLinkBrandMark extends StatelessWidget {
  const PetLinkBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pets, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'PetLink',
          style: PetTypography.label.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
