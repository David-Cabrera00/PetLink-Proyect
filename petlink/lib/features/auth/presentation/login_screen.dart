import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  static const _fieldFill = Color(0xFFF4F5F7);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Solo visual: todavía no existe persistencia de "Recordarme".
  bool _rememberMe = false;

  // Entrada del formulario (slide + fade).
  late final AnimationController _controller;
  late final Animation<Offset> _bodySlide;
  late final Animation<double> _bodyFade;

  // Balanceo continuo del perrito dentro de la cabecera.
  late final AnimationController _dogIdleController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(curved);
    _bodyFade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    _dogIdleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _controller.forward();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  Future<void> _continueWithGoogle() async {
    await ref.read(authProvider.notifier).loginWithGoogle();
  }

  @override
  void dispose() {
    _dogIdleController.dispose();
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: cs.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600
              ? PetSpacing.lg
              : PetSpacing.xxl;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, l10n),
                FadeTransition(
                  opacity: _bodyFade,
                  child: SlideTransition(
                    position: _bodySlide,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            PetSpacing.xl,
                            horizontalPadding,
                            PetSpacing.xxl,
                          ),
                          child: _buildForm(context, l10n, isLoading),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cabecera morada: marca a la izquierda, perrito (Hero) a la derecha.
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? cs.primaryContainer : cs.primary;
    final foreground = isDark ? cs.onPrimaryContainer : Colors.white;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PetSpacing.xs,
            PetSpacing.xs,
            PetSpacing.lg,
            PetSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: foreground,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/welcome'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: PetSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PetLink',
                            style: PetTypography.heading.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: foreground,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.authLoginDescription,
                            style: PetTypography.bodySmall.copyWith(
                              fontSize: 13,
                              height: 1.35,
                              color: foreground.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: PetSpacing.md),
                    _buildDog(foreground),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDog(Color foreground) {
    return AnimatedBuilder(
      animation: _dogIdleController,
      builder: (context, child) {
        final t = Curves.easeInOutSine.transform(_dogIdleController.value);
        return Transform.translate(
          offset: Offset(0, -4 * t),
          child: Transform.rotate(
            angle: -0.05 + 0.1 * t,
            alignment: const Alignment(0, 0.7),
            child: child,
          ),
        );
      },
      child: Hero(
        tag: 'auth-illustration-hero',
        child: SizedBox(
          width: 110,
          height: 110,
          child: Image.asset(
            'assets/illustrations/petlink_login_dog.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.pets_rounded, size: 56, color: foreground),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Formulario.
  // ---------------------------------------------------------------------------
  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? cs.primaryContainer : cs.primary;
    final buttonForeground = isDark ? cs.onPrimaryContainer : Colors.white;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authLoginTitle,
            style: PetTypography.heading.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: PetSpacing.xl),

          // Correo
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              context,
              hint: l10n.authEmail,
              prefixIcon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.authEmailRequired;
              }
              if (!value.contains('@')) {
                return l10n.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: PetSpacing.md),

          // Contraseña
          TextFormField(
            controller: _passwordController,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _inputDecoration(
              context,
              hint: l10n.authPassword,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: l10n.authPasswordVisibility,
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authPasswordRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: PetSpacing.sm),

          // Fila intermedia: Recordarme + Olvidé mi contraseña
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: BorderSide(color: cs.outline, width: 1.4),
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                ),
              ),
              const SizedBox(width: PetSpacing.xs),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Text(
                    'Recordarme',
                    style: PetTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                style: TextButton.styleFrom(
                  foregroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  textStyle: PetTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(l10n.authForgotPassword),
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.lg),

          // Botón principal (píldora)
          FilledButton(
            onPressed: isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: buttonColor,
              foregroundColor: buttonForeground,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.7),
              elevation: 3,
              shadowColor: buttonColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: PetTypography.button.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(l10n.authLogin),
          ),
          const SizedBox(height: PetSpacing.xl),

          // Separador
          Row(
            children: [
              Expanded(child: Divider(color: cs.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: PetSpacing.md),
                child: Text(
                  'O continuar con',
                  style: PetTypography.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: cs.outlineVariant)),
            ],
          ),
          const SizedBox(height: PetSpacing.lg),

          // Google
          _buildGoogleButton(context, l10n, isLoading),
          const SizedBox(height: PetSpacing.lg),

          // Enlace a registro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes una cuenta?',
                style: PetTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/register'),
                style: TextButton.styleFrom(
                  foregroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  textStyle: PetTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(l10n.authCreateAccount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: isDark ? cs.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _continueWithGoogle,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      )
                    : Icon(
                        Icons.g_mobiledata_rounded,
                        size: 32,
                        color: cs.primary,
                      ),
                const SizedBox(width: PetSpacing.xs),
                Text(
                  l10n.authContinueWithGoogle,
                  style: PetTypography.button.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    OutlineInputBorder border([
      Color color = Colors.transparent,
      double w = 1,
    ]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: w),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
      prefixIcon: Icon(prefixIcon, color: cs.onSurfaceVariant),
      suffixIcon: suffixIcon,
      suffixIconColor: cs.onSurfaceVariant,
      filled: true,
      fillColor: isDark ? cs.surfaceContainerHighest : _fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PetSpacing.lg,
        vertical: 18,
      ),
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(cs.primary, 1.6),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.6),
    );
  }
}
