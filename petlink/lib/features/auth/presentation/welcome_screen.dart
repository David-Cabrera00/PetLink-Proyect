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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 600
                  ? PetSpacing.lg
                  : PetSpacing.xxl;

              return Stack(
                children: [
                  Positioned(
                    top: -72,
                    right: -56,
                    child: _buildDecorativeOrb(
                      colorScheme.primary.withValues(alpha: 0.10),
                      190,
                    ),
                  ),
                  Positioned(
                    bottom: -96,
                    left: -72,
                    child: _buildDecorativeOrb(
                      theme.extension<PetThemeExtension>()!.accent.withValues(
                        alpha: 0.12,
                      ),
                      220,
                    ),
                  ),
                  SingleChildScrollView(
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
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: PetSpacing.md),
                              Text(
                                l10n.authWelcomeDescription,
                                style: PetTypography.body.copyWith(
                                  color: colorScheme.onSurfaceVariant,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeOrb(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final extension = PetThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: PetRadius.xxlAll,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: PetRadius.xlAll,
            ),
            child: Icon(Icons.pets, size: 36, color: extension.accent),
          ),
          const SizedBox(width: PetSpacing.md),
          Text(
            'PetLink',
            style: PetTypography.heading.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
