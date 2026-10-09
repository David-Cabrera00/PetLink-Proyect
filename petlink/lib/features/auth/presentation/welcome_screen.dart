import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_theme_extension.dart';
import '../../../core/theme/pet_typography.dart';
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
              child: SizedBox(
                width: double.infinity,
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
                          style: PetTypography.display.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Text(
                          l10n.authWelcomeDescription,
                          style: PetTypography.body.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                          onPressed: () => context.go('/register'),
                        ),
                      ],
                    ),
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
    final extension = PetThemeExtension.of(context);
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: PetRadius.xxlAll,
          ),
          child: Icon(Icons.pets, size: 48, color: extension.accent),
        ),
        const SizedBox(height: PetSpacing.md),
        Text(
          'PetLink',
          style: PetTypography.heading.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
