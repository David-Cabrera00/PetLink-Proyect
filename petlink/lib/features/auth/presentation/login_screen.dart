import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _pill = BorderRadius.all(Radius.circular(100));

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _illustrationController;
  late final Animation<double> _illustrationFloat;

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Flotado vertical muy sutil (8 px) en bucle suave.
    _illustrationFloat = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _illustrationController, curve: Curves.easeInOut),
    );

    _illustrationController.repeat(reverse: true);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _continueWithGoogle() async {
    await ref.read(authProvider.notifier).loginWithGoogle();
  }

  @override
  void dispose() {
    _illustrationController.dispose();
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
                _buildHero(context, l10n, horizontalPadding),
                Center(
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    AppLocalizations l10n,
    double horizontalPadding,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? cs.primaryContainer : cs.primary;
    final foreground = isDark ? cs.onPrimaryContainer : cs.onPrimary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            PetSpacing.sm,
            PetSpacing.sm,
            horizontalPadding,
            PetSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowLeft),
                color: foreground,
                onPressed: () => context.go('/welcome'),
              ),
              Center(child: _buildIllustration(foreground)),
              const SizedBox(height: PetSpacing.xl),
              Padding(
                padding: const EdgeInsets.only(left: PetSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authLoginTitle,
                      style: PetTypography.heading.copyWith(color: foreground),
                    ),
                    const SizedBox(height: PetSpacing.xs),
                    Text(
                      l10n.authLoginDescription,
                      style: PetTypography.bodySmall.copyWith(
                        color: foreground.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ilustración del login (PNG) con entrada suave y flotado vertical sutil.
  Widget _buildIllustration(Color foreground) {
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * 0.5).clamp(160.0, 220.0).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: child,
        ),
      ),
      child: AnimatedBuilder(
        animation: _illustrationFloat,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _illustrationFloat.value),
          child: child,
        ),
        child: SizedBox(
          height: height,
          child: Image.asset(
            'assets/illustrations/petlink_login_dog.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(PhosphorIconsRegular.pawPrint, size: height * 0.4, color: foreground),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isLoading,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _pillDecoration(
              context,
              label: l10n.authEmail,
              hint: l10n.authEmailHint,
              prefixIcon: const Icon(PhosphorIconsRegular.envelope),
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
          const SizedBox(height: PetSpacing.lg),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _pillDecoration(
              context,
              label: l10n.authPassword,
              hint: l10n.authPasswordHint,
              prefixIcon: const Icon(PhosphorIconsRegular.lockKey),
              suffixIcon: IconButton(
                tooltip: l10n.authPasswordVisibility,
                icon: Icon(
                  _obscurePassword
                      ? PhosphorIconsRegular.eye
                      : PhosphorIconsRegular.eyeSlash,
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: Text(l10n.authForgotPassword),
            ),
          ),
          const SizedBox(height: PetSpacing.sm),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: const RoundedRectangleBorder(borderRadius: _pill),
              textStyle: PetTypography.button,
            ),
            child: isLoading
                ? _buildLoader(cs.onPrimary)
                : Text(l10n.authLogin),
          ),
          const SizedBox(height: PetSpacing.md),
          OutlinedButton.icon(
            onPressed: isLoading ? null : _continueWithGoogle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: const RoundedRectangleBorder(borderRadius: _pill),
              side: BorderSide(color: cs.outlineVariant),
              foregroundColor: cs.onSurface,
              textStyle: PetTypography.button,
            ),
            icon: isLoading
                ? _buildLoader(cs.primary)
                : Icon(PhosphorIconsRegular.googleLogo, size: 28, color: cs.primary),
            label: Text(l10n.authContinueWithGoogle),
          ),
        ],
      ),
    );
  }

  InputDecoration _pillDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: _pill,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PetSpacing.xl,
        vertical: PetSpacing.lg,
      ),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(cs.primary, 1.5),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error, 1.5),
    );
  }

  Widget _buildLoader(Color color) {
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
    );
  }
}
