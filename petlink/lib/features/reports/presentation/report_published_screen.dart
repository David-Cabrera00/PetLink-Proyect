import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';

class ReportPublishedScreen extends ConsumerWidget {
  const ReportPublishedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: PetColors.foundSoft,
                  borderRadius: PetRadius.xxlAll,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: PetColors.found,
                ),
              ),
              const SizedBox(height: PetSpacing.xl),
              Text(
                'Tu reporte ya está activo',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PetSpacing.md),
              Text(
                'Las personas cerca podrán verlo y PetLink buscará posibles coincidencias.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PetSpacing.xl),
              PetButton(
                label: 'Ver mi reporte',
                onPressed: () => context.go('/reports'),
                icon: Icons.description,
              ),
              const SizedBox(height: PetSpacing.md),
              OutlinedButton(
                onPressed: () => context.go('/radar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
                ),
                child: const Text('Volver al radar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
