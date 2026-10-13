import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_theme_extension.dart';
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
  late final Animation<double> _imageOpacity;
  late final Animation<double> _imageScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener(_handleAnimationStatus);

    _imageOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _imageScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.84, curve: Curves.easeOut),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.32, 0.9, curve: Curves.easeOutCubic),
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
    final extension = PetThemeExtension.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _continue,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = (constraints.maxWidth * 0.72)
                  .clamp(210.0, 330.0)
                  .toDouble();

              final minHeight = constraints.maxHeight.isFinite
                  ? math.max(0.0, constraints.maxHeight - PetSpacing.lg * 2)
                  : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(PetSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _imageOpacity,
                        child: ScaleTransition(
                          scale: _imageScale,
                          child: Container(
                            width: imageSize,
                            height: imageSize,
                            padding: const EdgeInsets.all(PetSpacing.md),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(
                                alpha: 0.42,
                              ),
                              borderRadius: PetRadius.xxlAll,
                              border: Border.all(
                                color: extension.accent.withValues(alpha: 0.38),
                              ),
                            ),
                            child: Image.asset(
                              'assets/illustrations/petlink_welcome.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    PhosphorIconsRegular.path,
                                    size: imageSize * 0.28,
                                    color: cs.primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: PetSpacing.xl),
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SlideTransition(
                          position: _textOffset,
                          child: Column(
                            children: [
                              Text(
                                'PetLink',
                                style: PetTypography.display.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: PetSpacing.sm),
                              Text(
                                l10n.authWelcomeTitle,
                                textAlign: TextAlign.center,
                                style: PetTypography.heading.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
