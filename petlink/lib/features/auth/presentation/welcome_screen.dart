import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
    this.opacity, {
    this.rangeX = 16.0,
    this.rangeY = 20.0,
    this.phase = 0.0,
  });

  final String asset;

  /// Posición horizontal (centro) y vertical (borde superior) como fracción.
  final double dx;
  final double dy;
  final double size;
  final double angle;
  final double opacity;
  final double rangeX;
  final double rangeY;
  final double phase;
}

const _paw = 'assets/decorations/paw_prints.png';
const _pin = 'assets/decorations/location_pin.png';

// Distribución orgánica por toda la pantalla con amplitudes de 12 a 24 px y desfases desincronizados
const _decorations = <_Decoration>[
  // --- Zona Superior (arriba del card, laterales y centro-alto) ---
  _Decoration(
    _paw,
    0.88,
    0.06,
    26,
    0.4,
    0.22,
    rangeX: 14,
    rangeY: 18,
    phase: 0.0,
  ),
  _Decoration(
    _paw,
    0.52,
    0.10,
    24,
    -0.3,
    0.20,
    rangeX: 18,
    rangeY: 15,
    phase: 1.2,
  ),
  _Decoration(
    _paw,
    0.12,
    0.16,
    28,
    -0.4,
    0.24,
    rangeX: 15,
    rangeY: 22,
    phase: 2.5,
  ),
  _Decoration(
    _pin,
    0.76,
    0.14,
    22,
    0,
    0.22,
    rangeX: 12,
    rangeY: 16,
    phase: 3.8,
  ),
  _Decoration(
    _paw,
    0.40,
    0.20,
    20,
    0.5,
    0.18,
    rangeX: 16,
    rangeY: 20,
    phase: 4.5,
  ),
  _Decoration(
    _pin,
    0.89,
    0.25,
    20,
    0,
    0.20,
    rangeX: 20,
    rangeY: 15,
    phase: 0.8,
  ),
  _Decoration(
    _paw,
    0.18,
    0.28,
    30,
    0.6,
    0.22,
    rangeX: 14,
    rangeY: 24,
    phase: 5.2,
  ),

  // --- Zona Media / Laterales (afuera del card en pantallas más anchas o bordes) ---
  _Decoration(
    _paw,
    0.93,
    0.45,
    26,
    -0.35,
    0.20,
    rangeX: 16,
    rangeY: 18,
    phase: 2.1,
  ),
  _Decoration(
    _pin,
    0.06,
    0.48,
    22,
    0,
    0.20,
    rangeX: 13,
    rangeY: 20,
    phase: 3.4,
  ),
  _Decoration(
    _paw,
    0.90,
    0.62,
    28,
    0.3,
    0.22,
    rangeX: 18,
    rangeY: 16,
    phase: 1.7,
  ),
  _Decoration(
    _paw,
    0.08,
    0.68,
    24,
    0.5,
    0.20,
    rangeX: 15,
    rangeY: 22,
    phase: 4.1,
  ),

  // --- Zona Inferior (debajo y en esquinas inferiores) ---
  _Decoration(
    _pin,
    0.15,
    0.84,
    24,
    0,
    0.20,
    rangeX: 14,
    rangeY: 18,
    phase: 0.5,
  ),
  _Decoration(
    _paw,
    0.84,
    0.86,
    28,
    -0.4,
    0.22,
    rangeX: 20,
    rangeY: 14,
    phase: 3.0,
  ),
  _Decoration(
    _paw,
    0.48,
    0.93,
    24,
    0.25,
    0.18,
    rangeX: 16,
    rangeY: 20,
    phase: 5.8,
  ),
  _Decoration(
    _paw,
    0.12,
    0.95,
    26,
    -0.2,
    0.20,
    rangeX: 18,
    rangeY: 16,
    phase: 2.8,
  ),
];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    // Animación ambiental de fondo suave y continua (8 segundos en reverse continuo)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    // Paleta adaptativa para el fondo según modo claro / oscuro
    final gradientColors = isDark
        ? [cs.primary.withValues(alpha: 0.78), cs.primary]
        : [
            const Color(0xFFE0F2F1),
            const Color(0xFFB2DFDB),
          ]; // Teal muy claro / aqua suave

    final overlayColors = isDark
        ? [cs.primary.withValues(alpha: 0.28), cs.scrim.withValues(alpha: 0.78)]
        : [
            Colors.white.withValues(alpha: 0.40),
            const Color(0xFF80CBC4).withValues(alpha: 0.25),
          ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Degradado base
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: overlayColors,
              ),
            ),
          ),

          // 2. Capa de elementos decorativos flotantes animados
          Positioned.fill(child: _buildDecorations(isDark)),

          // 3. Contenido en primer plano (Wordmark y tarjeta de bienvenida)
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
                        _buildWordmark(context, isDark),
                        SizedBox(height: constraints.maxHeight * 0.28),
                        _buildGlassContent(context, l10n, isDark),
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

  /// Capa de fondo animada continuamente con AnimatedBuilder e IgnorePointer
  Widget _buildDecorations(bool isDark) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, _) {
              final t = _backgroundController.value * 2 * math.pi;

              return Stack(
                children: [
                  for (final item in _decorations)
                    _FloatingItem(
                      item: item,
                      screenWidth: width,
                      screenHeight: height,
                      t: t,
                      isDark: isDark,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWordmark(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark ? cs.surface.withValues(alpha: 0.88) : Colors.white,
            borderRadius: PetRadius.mdAll,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(
            PhosphorIconsRegular.pawPrint,
            color: cs.primary,
            size: 19,
          ),
        ),
        const SizedBox(width: PetSpacing.sm),
        Text(
          'PetLink',
          style: PetTypography.title.copyWith(
            color: isDark ? Colors.white : cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassContent(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final cs = Theme.of(context).colorScheme;

    final cardBg = isDark
        ? cs.surface.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.82);

    final cardBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.42))
        : Border.all(color: Colors.white.withValues(alpha: 0.90), width: 1.5);

    final titleColor = isDark ? Colors.white : const Color(0xFF103943);
    final descColor = isDark
        ? Colors.white.withValues(alpha: 0.86)
        : const Color(0xFF37474F);

    return ClipRRect(
      borderRadius: PetRadius.xxlAll,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(PetSpacing.xl),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: PetRadius.xxlAll,
            border: cardBorder,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF004D40).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authWelcomeTitle,
                style: PetTypography.display.copyWith(
                  color: titleColor,
                  fontSize: 34,
                  height: 1.08,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: PetSpacing.md),
              Text(
                l10n.authWelcomeDescription,
                style: PetTypography.body.copyWith(
                  color: descColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: PetSpacing.xl),
              PetButton(
                label: l10n.authLogin,
                variant: PetButtonVariant.primary,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: PetSpacing.sm),
              PetButton(
                label: l10n.authCreateAccount,
                variant: isDark
                    ? PetButtonVariant.secondary
                    : PetButtonVariant.outline,
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget auxiliar que oscila individualmente en su propia fase y trayectoria elíptica
class _FloatingItem extends StatelessWidget {
  final _Decoration item;
  final double screenWidth;
  final double screenHeight;
  final double t;
  final bool isDark;

  const _FloatingItem({
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    required this.t,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Desplazamiento armónico orgánico y desfasado con seno y coseno
    final offsetX = math.sin(t + item.phase) * item.rangeX;
    final offsetY = math.cos(t + item.phase) * item.rangeY;

    final baseX = screenWidth * item.dx - item.size / 2;
    final baseY = screenHeight * item.dy;

    final opacity = isDark
        ? item.opacity
        : (item.opacity * 1.35).clamp(0.15, 0.35);

    return Positioned(
      left: baseX + offsetX,
      top: baseY + offsetY,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: item.angle + (math.sin(t + item.phase) * 0.08),
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
    );
  }
}
