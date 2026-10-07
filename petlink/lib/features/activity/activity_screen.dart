import 'package:flutter/material.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actividad')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications,
                size: 64,
                color: PetColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: PetSpacing.lg),
              Text(
                'Actividad Reciente',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                'Recibe notificaciones sobre coincidencias y actualizaciones.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
