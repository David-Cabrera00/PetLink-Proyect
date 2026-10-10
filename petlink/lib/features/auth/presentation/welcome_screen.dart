import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/widgets/animal_pattern_field.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withValues(alpha: 0.78),
                  cs.primary,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: AnimalPatternField(
              colors: [
                cs.tertiary,
                cs.secondary,
                cs.onPrimary,
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: 0.28),
                  cs.scrim.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 600
                    ? PetSpacing.lg
                    : PetSpacing.xxl;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    PetSpacing.lg,
                    horizontalPadding,
                    PetSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - PetSpacing.xl,
                      maxWidth: 520,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWordmark(context),
                        SizedBox(height: constraints.maxHeight * 0.28),
                        _buildGlassContent(context, l10n),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordmark(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.88),
            borderRadius: PetRadius.mdAll,
          ),
          child: Icon(Icons.pets, color: cs.primary, size: 19),
        ),
        const SizedBox(width: PetSpacing.sm),
        Text(
          'PetLink',
          style: PetTypography.title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: PetRadius.xxlAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(PetSpacing.xl),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.18),
            borderRadius: PetRadius.xxlAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authWelcomeTitle,
                style: PetTypography.display.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.08,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: PetSpacing.md),
              Text(
                l10n.authWelcomeDescription,
                style: PetTypography.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: PetSpacing.xl),
              PetButton(
                label: l10n.authLogin,
                variant: PetButtonVariant.accent,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: PetSpacing.sm),
              PetButton(
                label: l10n.authCreateAccount,
                variant: PetButtonVariant.lightOutline,
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
