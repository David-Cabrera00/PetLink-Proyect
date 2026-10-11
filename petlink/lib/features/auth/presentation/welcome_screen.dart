import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../../../design_system/buttons/pet_button.dart';

class _Decoration {
  const _Decoration(
    this.asset,
    this.dx,
    this.dy,
    this.size,
    this.angle,
    this.opacity,
  );

  final String asset;

  /// Posición horizontal (centro) y vertical (borde superior) como fracción.
  final double dx;
  final double dy;
  final double size;
  final double angle;
  final double opacity;
}

const _paw = 'assets/decorations/paw_prints.png';
const _pin = 'assets/decorations/location_pin.png';

// Distribución orgánica por toda la pantalla (superior, media y baja/lateral)
// evitando el wordmark y no compitiendo con el card.
const _decorations = <_Decoration>[
  // --- Zona Superior (arriba del card, laterales y centro-alto) ---
  _Decoration(_paw, 0.88, 0.06, 26, 0.4, 0.22),
  _Decoration(_paw, 0.52, 0.10, 24, -0.3, 0.20),
  _Decoration(_paw, 0.12, 0.16, 28, -0.4, 0.24),
  _Decoration(_pin, 0.76, 0.14, 22, 0, 0.22),
  _Decoration(_paw, 0.40, 0.20, 20, 0.5, 0.18),
  _Decoration(_pin, 0.89, 0.25, 20, 0, 0.20),
  _Decoration(_paw, 0.18, 0.28, 30, 0.6, 0.22),

  // --- Zona Media / Laterales (afuera del card en pantallas más anchas o bordes) ---
  _Decoration(_paw, 0.93, 0.45, 26, -0.35, 0.20),
  _Decoration(_pin, 0.06, 0.48, 22, 0, 0.20),
  _Decoration(_paw, 0.90, 0.62, 28, 0.3, 0.22),
  _Decoration(_paw, 0.08, 0.68, 24, 0.5, 0.20),

  // --- Zona Inferior (debajo y en esquinas inferiores) ---
  _Decoration(_pin, 0.15, 0.84, 24, 0, 0.20),
  _Decoration(_paw, 0.84, 0.86, 28, -0.4, 0.22),
  _Decoration(_paw, 0.48, 0.93, 24, 0.25, 0.18),
  _Decoration(_paw, 0.12, 0.95, 26, -0.2, 0.20),
];

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
                colors: [cs.primary.withValues(alpha: 0.78), cs.primary],
              ),
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
          Positioned.fill(child: _buildDecorations()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 600
                    ? PetSpacing.lg
                    : PetSpacing.xxl;

                final minHeight = constraints.maxHeight.isFinite
                    ? math.max(0.0, constraints.maxHeight - (PetSpacing.lg * 2))
                    : 0.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    PetSpacing.lg,
                    horizontalPadding,
                    PetSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHeight,
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

  /// Huellas y pins pequeños y sutiles, ubicados en la zona superior/lateral
  /// (por encima del card) con posiciones fraccionales irregulares.
  Widget _buildDecorations() {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              for (final item in _decorations)
                Positioned(
                  left: width * item.dx - item.size / 2,
                  top: height * item.dy,
                  child: Opacity(
                    opacity: item.opacity,
                    child: Transform.rotate(
                      angle: item.angle,
                      child: Image.asset(
                        item.asset,
                        width: item.size,
                        height: item.size,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
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

  Widget _buildGlassContent(BuildContext context, AppLocalizations l10n) {
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
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
                variant: PetButtonVariant.secondary,
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
