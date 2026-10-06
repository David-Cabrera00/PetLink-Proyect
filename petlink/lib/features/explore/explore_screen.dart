import 'package:flutter/material.dart';
import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map,
                size: 64,
                color: PetColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: PetSpacing.lg),
              Text(
                'Mapa de Exploración',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                'Explora el mapa para ver reportes de mascotas en tu zona.',
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
