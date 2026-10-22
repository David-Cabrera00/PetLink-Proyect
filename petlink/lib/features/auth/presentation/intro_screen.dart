import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../providers/auth_provider.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _progressAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener(_handleAnimationStatus);

    // Halo de luz de fondo
    _glowScale = Tween<double>(begin: 0.70, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    // Entrada elástica de la tarjeta del perrito
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
          ),
        );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Entrada del texto de bienvenida
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.80, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.32, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // Micro-indicador de carga en la base
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _continue();
  }

  void _continue() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final destination = ref.read(authProvider).isAuthenticated
        ? '/radar'
        : '/welcome';
    context.go(destination);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Gradiente ambiental sutil que armoniza directamente con la pantalla de Welcome
    final bgGradientColors = isDark
        ? [cs.surface, Color.lerp(cs.surface, cs.primaryContainer, 0.35)!]
        : [const Color(0xFFF9FBFA), const Color(0xFFE8F4F2)];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _continue,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fondo degradado ambiental
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: bgGradientColors,
                ),
              ),
            ),

            // 2. Halo de resplandor difuminado (ambient glow)
            Center(
              child: AnimatedBuilder(
                animation: _glowScale,
                builder: (context, child) {
                  return Transform.scale(scale: _glowScale.value, child: child);
                },
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                        cs.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Contenido principal perfectamente centrado y seguro
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final badgeSize = (constraints.maxWidth * 0.58)
                      .clamp(180.0, 250.0)
                      .toDouble();

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PetSpacing.xl,
                        vertical: PetSpacing.lg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge central de la mascota con animación suave
                          FadeTransition(
                            opacity: _logoOpacity,
                            child: SlideTransition(
                              position: _logoSlide,
                              child: ScaleTransition(
                                scale: _logoScale,
                                child: Container(
                                  width: badgeSize,
                                  height: badgeSize,
                                  padding: const EdgeInsets.all(PetSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? cs.surfaceContainerHighest
                                        : Colors.white,
                                    borderRadius: PetRadius.xxlAll,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.25 : 0.07,
                                        ),
                                        blurRadius: 32,
                                        offset: const Offset(0, 14),
                                      ),
                                      BoxShadow(
                                        color: cs.primary.withValues(
                                          alpha: isDark ? 0.20 : 0.14,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Hero(
                                    tag: 'auth-illustration-hero',
                                    child: Image.asset(
                                      'assets/illustrations/petlink_login_dog.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.pets_rounded,
                                            size: badgeSize * 0.45,
                                            color: cs.primary,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: PetSpacing.xl),

                          // Tipografía destacada y eslogan
                          FadeTransition(
                            opacity: _textOpacity,
                            child: SlideTransition(
                              position: _textSlide,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: cs.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.pets_rounded,
                                          size: 20,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(width: PetSpacing.sm),
                                      Text(
                                        'PetLink',
                                        style: PetTypography.display.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 34,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: PetSpacing.xs),
                                  Text(
                                    l10n.authWelcomeTitle,
                                    textAlign: TextAlign.center,
                                    style: PetTypography.body.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: PetSpacing.xxl),

                          // Micro-indicador elegante de inicio en la base
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, _) {
                              return FadeTransition(
                                opacity: _textOpacity,
                                child: Container(
                                  width: 44,
                                  height: 3.5,
                                  decoration: BoxDecoration(
                                    color: cs.outlineVariant.withValues(
                                      alpha: 0.35,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _progressAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cs.primary,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: cs.primary.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
