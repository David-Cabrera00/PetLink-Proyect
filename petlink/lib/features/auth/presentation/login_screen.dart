import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/pet_tokens.dart';
import '../providers/auth_provider.dart';
import 'widgets/reactive_pet_avatar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _lookAtEmail = false;
  bool _coverEyes = false;
  bool _peeking = false;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _lookAtEmail = _emailFocus.hasFocus;
      _coverEyes = _passwordFocus.hasFocus;
      _peeking = _passwordFocus.hasFocus && !_obscurePassword;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      _peeking = _passwordFocus.hasFocus && !_obscurePassword;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(apiErrorMessage(l10n, error, isLogin: true))),
        );
    }
  }

  Future<void> _continueWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.authGoogleUnavailable)));
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(authProvider).isLoading;
    final bg = isDark ? PetTokens.plumDeep : PetTokens.cream;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header ciruela con curva y mascota reactiva
            _LoginHeader(
              lookAtEmail: _lookAtEmail,
              coverEyes: _coverEyes,
              peeking: _peeking,
            ),

            // 2. Formulario principal
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter + 4,
                24,
                PetTokens.gutter + 4,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo Correo
                        _FieldLabel(label: l10n.authEmail),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: 'tu@correo.com',
                            prefixIcon: Icons.mail_outline_rounded,
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
                        const SizedBox(height: 18),

                        // Campo Contraseña
                        _FieldLabel(label: l10n.authPassword),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              tooltip: l10n.authPasswordVisibility,
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: PetTokens.muted2,
                                size: 20,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.authPasswordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Botón Entrar primario
                        _PrimaryButton(
                          label: l10n.authLogin,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),

                        // Botón Google alternativo
                        _GoogleButton(
                          label: l10n.authContinueWithGoogle,
                          isLoading: isLoading,
                          onPressed: _continueWithGoogle,
                        ),
                        const SizedBox(height: 24),

                        // Enlace a Crear cuenta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authNoAccount,
                              style: PetTokens.body(
                                15,
                                color: PetTokens.mutedOf(context),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                l10n.authCreateAccount,
                                style: PetTokens.body(
                                  15,
                                  color: PetTokens.lostTextOf(context),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),

                        // Lema al pie
                        Text(
                          l10n.authTagline,
                          textAlign: TextAlign.center,
                          style: PetTokens.display(
                            15,
                            color: PetTokens.mutedOf(context),
                            italic: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: PetTokens.body(16, color: PetTokens.mutedOf(context)),
      prefixIcon: Icon(prefixIcon, color: PetTokens.muted2, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: PetTokens.surfaceHigherOf(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        borderSide: BorderSide(color: PetTokens.borderOf(context), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        borderSide: BorderSide(color: PetTokens.borderOf(context), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        borderSide: BorderSide(color: PetTokens.plumAccentOf(context), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        borderSide: BorderSide(color: PetTokens.lostBorderOf(context), width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: PetTokens.body(13, color: PetTokens.inkOf(context), weight: FontWeight.w700),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({
    required this.lookAtEmail,
    required this.coverEyes,
    required this.peeking,
  });

  final bool lookAtEmail;
  final bool coverEyes;
  final bool peeking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo SVG con curva de colina
          Positioned.fill(
            child: CustomPaint(
              painter: const _LoginHeaderPainter(),
            ),
          ),

          // Botón volver
          Positioned(
            left: 16,
            top: top + 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => context.go('/welcome'),
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: PetTokens.cream,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Título del header
          Positioned(
            left: 24,
            top: top + 64,
            right: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authHelloAgain,
                  style: PetTokens.eyebrow(color: PetTokens.peach),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: PetTokens.display(36, color: PetTokens.cream),
                    children: [
                      TextSpan(text: l10n.authWeWereWaiting),
                      TextSpan(
                        text: l10n.authWaitingForYou,
                        style: PetTokens.display(
                          36,
                          color: PetTokens.clayOnDark,
                          italic: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mascota interactiva sobre la curva de colina
          Positioned(
            right: 16,
            bottom: 12,
            child: ReactivePetAvatar(
              size: 150,
              lookAtEmail: lookAtEmail,
              coverEyes: coverEyes,
              peeking: peeking,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeaderPainter extends CustomPainter {
  const _LoginHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curva de colina: M0 0H390V270Q300 330 195 300T0 290Z
    final hill = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.81)
      ..quadraticBezierTo(w * 0.77, h * 1.0, w * 0.50, h * 0.91)
      ..quadraticBezierTo(w * 0.23, h * 0.82, 0, h * 0.88)
      ..close();

    canvas.drawPath(hill, Paint()..color = PetTokens.plum);

    // Líneas decorativas topográficas
    final linePaint = Paint()
      ..color = PetTokens.plumLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final dy in [0.36, 0.48, 0.60]) {
      final p = Path()
        ..moveTo(-20, h * dy)
        ..quadraticBezierTo(w * 0.35, h * (dy - 0.15), w * 0.55, h * dy)
        ..quadraticBezierTo(w * 0.85, h * (dy + 0.15), w + 20, h * dy);
      canvas.drawPath(p, linePaint);
    }
  }

  @override
  bool shouldRepaint(_LoginHeaderPainter oldDelegate) => false;
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PetTokens.rButton),
        boxShadow: PetTokens.shadowButton,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PetTokens.isDark(context) ? PetTokens.clay : PetTokens.plum,
          foregroundColor: Colors.white,
          disabledBackgroundColor: (PetTokens.isDark(context) ? PetTokens.clay : PetTokens.plum).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PetTokens.rButton),
          ),
          elevation: 0,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: PetTokens.body(
                      16,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: PetTokens.surface,
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        border: Border.all(color: PetTokens.border, width: 1.5),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.g_mobiledata_rounded,
              size: 30,
              color: PetTokens.plum,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: PetTokens.body(
                15,
                color: PetTokens.ink,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
