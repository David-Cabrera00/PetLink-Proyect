import 'package:flutter/material.dart';
import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.radar,
                size: 64,
                color: PetColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: PetSpacing.lg),
              Text(
                'Radar de Mascotas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                'Aquí verás las mascotas perdidas y encontradas cerca de tu ubicación.',
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
