import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/widgets/animal_pattern_field.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _horizontalAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    _horizontalAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -6,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -6,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -6,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -6,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
          Positioned.fill(
            child: AnimalPatternField(
              colors: [cs.tertiary, cs.secondary, cs.onPrimary],
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

                final topSpacing = (constraints.maxHeight * 0.05).clamp(
                  PetSpacing.md,
                  PetSpacing.xl,
                );

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
                        SizedBox(height: topSpacing),
                        _buildAnimatedPetSection(context, constraints.maxWidth),
                        SizedBox(height: topSpacing),
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

  /// Sección animada con mascota trotando y huellas sutiles que aparecen detrás.
  Widget _buildAnimatedPetSection(BuildContext context, double maxWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGlow = isDark ? Colors.tealAccent : Colors.white;

    final travelRange = (maxWidth.clamp(320.0, 480.0) - 160).clamp(60.0, 160.0);

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final progress = _horizontalAnim.value;
          final currentX = (progress * travelRange) - (travelRange / 2);
          final isMovingRight =
              _animController.status == AnimationStatus.forward;
          final bounceY = _bounceAnim.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Línea sutil de sendero / camino
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primaryGlow.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Huellas sutiles que pulsan o se van desvaneciendo
              ..._buildPawsTrack(progress, travelRange, primaryGlow),
              // Mascota / perrito trotando
              Transform.translate(
                offset: Offset(currentX, bounceY),
                child: Transform.flip(
                  flipX: !isMovingRight,
                  child: _buildRunningPetAvatar(primaryGlow),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Huellitas estáticas/sutiles a lo largo de la trayectoria
  List<Widget> _buildPawsTrack(
    double progress,
    double travelRange,
    Color glowColor,
  ) {
    const pawSteps = 4;
    return List.generate(pawSteps, (index) {
      final stepFraction = (index + 0.5) / pawSteps;
      final xPos = (stepFraction * travelRange) - (travelRange / 2);
      final distance = (progress - stepFraction).abs();
      final alpha = (1.0 - (distance * 2.8)).clamp(0.08, 0.40);
      final offsetY = (index % 2 == 0 ? -3.0 : 3.0);

      return Transform.translate(
        offset: Offset(xPos, 14.0 + offsetY),
        child: Icon(
          Icons.pets,
          size: 13,
          color: glowColor.withValues(alpha: alpha),
        ),
      );
    });
  }

  /// Avatar circular con estilizado minimalista que representa la mascota en movimiento
  Widget _buildRunningPetAvatar(Color glowColor) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.25),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.92),
              ),
              child: const Icon(
                Icons.pets,
                size: 24,
                color: Color(0xFF0F766E), // PetLink Teal primario
              ),
            ),
          ],
        ),
      ),
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
