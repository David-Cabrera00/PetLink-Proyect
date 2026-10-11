import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_theme_extension.dart';
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
                        _buildHeroIllustration(context),
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

  /// Placeholder abstracto preparado para sustituirse por una ilustración real.
  Widget _buildHeroIllustration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = PetThemeExtension.of(context).accent;
    return SizedBox(
      height: 168,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.12),
          borderRadius: PetRadius.xxlAll,
          border: Border.all(color: cs.onPrimary.withValues(alpha: 0.24)),
        ),
        child: ClipRRect(
          borderRadius: PetRadius.xxlAll,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                math.sin(_horizontalAnim.value * math.pi * 2) * 2,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetSpacing.lg,
                  vertical: PetSpacing.sm,
                ),
                child: Semantics(
                  image: true,
                  label: 'Ilustración de PetLink',
                  child: Image.asset(
                    'assets/illustrations/petlink_welcome.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => CustomPaint(
                      painter: _WelcomeHeroPainter(
                        progress: _horizontalAnim.value,
                        routeColor: cs.onPrimary.withValues(alpha: 0.42),
                        accentColor: accent,
                        markerColor: cs.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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

class _WelcomeHeroPainter extends CustomPainter {
  const _WelcomeHeroPainter({
    required this.progress,
    required this.routeColor,
    required this.accentColor,
    required this.markerColor,
  });

  final double progress;
  final Color routeColor;
  final Color accentColor;
  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(size.width * 0.10, size.height * 0.72)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.42,
        size.width * 0.48,
        size.height * 0.92,
        size.width * 0.76,
        size.height * 0.32,
      );
    canvas.drawPath(route, routePaint);

    final animatedPoint = Offset(
      size.width * (0.20 + progress * 0.45),
      size.height * (0.64 - math.sin(progress * math.pi) * 0.16),
    );
    _drawPaw(canvas, animatedPoint, accentColor.withValues(alpha: 0.88), 11);
    _drawPaw(
      canvas,
      Offset(size.width * 0.38, size.height * 0.68),
      markerColor.withValues(alpha: 0.56),
      9,
    );
    _drawPaw(
      canvas,
      Offset(size.width * 0.56, size.height * 0.47),
      markerColor.withValues(alpha: 0.42),
      8,
    );
    _drawPin(
      canvas,
      Offset(size.width * 0.79, size.height * 0.25),
      accentColor,
    );
  }

  void _drawPaw(Canvas canvas, Offset center, Color color, double size) {
    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size * 0.85,
        height: size * 0.64,
      ),
      paint,
    );

    for (var index = 0; index < 3; index++) {
      final angle = -0.95 + index * 0.95;
      canvas.drawCircle(
        center + Offset(math.cos(angle) * size * 0.34, math.sin(angle) * size * 0.34),
        size * 0.14,
        paint,
      );
    }
  }

  void _drawPin(Canvas canvas, Offset center, Color color) {
    final pinPath = Path()
      ..moveTo(center.dx, center.dy + 17)
      ..cubicTo(
        center.dx - 14,
        center.dy + 2,
        center.dx - 12,
        center.dy - 11,
        center.dx,
        center.dy - 11,
      )
      ..cubicTo(
        center.dx + 12,
        center.dy - 11,
        center.dx + 14,
        center.dy + 2,
        center.dx,
        center.dy + 17,
      );
    canvas.drawPath(pinPath, Paint()..color = color.withValues(alpha: 0.9));
    canvas.drawCircle(
      Offset(center.dx, center.dy - 2),
      4,
      Paint()..color = markerColor,
    );
  }

  @override
  bool shouldRepaint(covariant _WelcomeHeroPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.routeColor != routeColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.markerColor != markerColor;
}
