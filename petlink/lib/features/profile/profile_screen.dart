import 'package:flutter/material.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 64,
                color: PetColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: PetSpacing.lg),
              Text(
                'Mi Perfil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: PetSpacing.sm),
              Text(
                'Gestiona tu información personal y configuración.',
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
