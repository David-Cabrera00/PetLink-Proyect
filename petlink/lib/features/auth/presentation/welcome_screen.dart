import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/buttons/pet_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600
                ? PetSpacing.lg
                : PetSpacing.xxl;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: PetSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox(
                  height: constraints.maxHeight - (PetSpacing.xl * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBrand(context),
                      const SizedBox(height: PetSpacing.xxl),
                      Text(
                        l10n.authWelcomeTitle,
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PetSpacing.md),
                      Text(
                        l10n.authWelcomeDescription,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      PetButton(
                        label: l10n.authLogin,
                        onPressed: () => context.go('/login'),
                      ),
                      const SizedBox(height: PetSpacing.md),
                      PetButton(
                        label: l10n.authCreateAccount,
                        variant: PetButtonVariant.outline,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: PetRadius.xxlAll,
          ),
          child: Icon(Icons.pets, size: 48, color: PetColors.primary),
        ),
        const SizedBox(height: PetSpacing.md),
        Text(
          'PetLink',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
