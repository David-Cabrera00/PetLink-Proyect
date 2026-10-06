import 'package:flutter/material.dart';
import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: 64,
                color: PetColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: PetSpacing.lg),
              Text(
                'Mis Reportes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                'Gestiona tus reportes de mascotas perdidas y encontradas.',
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
