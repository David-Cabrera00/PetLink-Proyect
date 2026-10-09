import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';

class ReportPublishedScreen extends ConsumerWidget {
  const ReportPublishedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                l10n.reportPublishedTitle,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PetSpacing.md),
              Text(
                l10n.reportPublishedDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: PetSpacing.xl),
              PetButton(
                label: l10n.viewMyReport,
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
                child: Text(l10n.backToRadar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
