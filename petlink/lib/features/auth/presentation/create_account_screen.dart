import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/pet_tokens.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../providers/auth_provider.dart';
import 'widgets/reactive_pet_avatar.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  bool _coverEyes = false;
  bool _peeking = false;
  int _passwordLength = 0;

  @override
  void initState() {
    super.initState();

    _passwordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
    _passwordController.addListener(_onPasswordChange);
  }

  void _onFocusChange() {
    setState(() {
      final isPwFocused = _passwordFocus.hasFocus;
      final isConfirmFocused = _confirmPasswordFocus.hasFocus;
      _coverEyes = isPwFocused || isConfirmFocused;

      if (isPwFocused) {
        _peeking = !_obscurePassword;
      } else if (isConfirmFocused) {
        _peeking = !_obscureConfirmation;
      } else {
        _peeking = false;
      }
    });
  }

  void _onPasswordChange() {
    setState(() {
      _passwordLength = _passwordController.text.length;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
      if (_passwordFocus.hasFocus) {
        _peeking = !_obscurePassword;
      }
    });
  }

  void _toggleConfirmationVisibility() {
    setState(() {
      _obscureConfirmation = !_obscureConfirmation;
      if (_confirmPasswordFocus.hasFocus) {
        _peeking = !_obscureConfirmation;
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(apiErrorMessage(l10n, error))),
        );
    }
  }

  @override
  void dispose() {
    _passwordFocus.removeListener(_onFocusChange);
    _confirmPasswordFocus.removeListener(_onFocusChange);
    _passwordController.removeListener(_onPasswordChange);
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            // 1. Cabecera ciruela con mascota que ladea la cabeza
            _RegisterHeader(
              coverEyes: _coverEyes,
              peeking: _peeking,
            ),

            // 2. Formulario
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter + 4,
                20,
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
                        // Nombre
                        _FieldLabel(label: l10n.authName),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: 'Nombre',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.authNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Correo
                        _FieldLabel(label: l10n.authEmail),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: 'Correo electrónico',
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
                        const SizedBox(height: 14),

                        // Contraseña
                        _FieldLabel(label: l10n.authPassword),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: 'Contraseña',
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
                        const SizedBox(height: 8),

                        // Medidor de fuerza de 4 huellas según el diseño
                        _PasswordStrengthMeter(length: _passwordLength),
                        const SizedBox(height: 14),

                        // Confirmar contraseña
                        _FieldLabel(label: l10n.authConfirmPassword),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          obscureText: _obscureConfirmation,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: PetTokens.bodyThemed(context, 16, color: PetTokens.inkOf(context)),
                          decoration: _inputDecoration(
                            hint: 'Confirmar contraseña',
                            prefixIcon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              tooltip: l10n.authPasswordVisibility,
                              icon: Icon(
                                _obscureConfirmation
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: PetTokens.muted2,
                                size: 20,
                              ),
                              onPressed: _toggleConfirmationVisibility,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.authConfirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return l10n.authPasswordsMismatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botón Crear cuenta
                        _RegisterButton(
                          label: l10n.authCreateAccount,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),

                        // Enlace a Iniciar sesión
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.authAlreadyHaveAccount,
                              style: PetTokens.body(
                                15,
                                color: PetTokens.mutedOf(context),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                l10n.authLogin,
                                style: PetTokens.body(
                                  15,
                                  color: PetTokens.lostTextOf(context),
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Lema
                        Text(
                          'Cada huella cuenta.',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.coverEyes,
    required this.peeking,
  });

  final bool coverEyes;
  final bool peeking;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo curva
          Positioned.fill(
            child: CustomPaint(
              painter: const _RegisterHeaderPainter(),
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

          // Título
          Positioned(
            left: 24,
            top: top + 54,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: PetTokens.display(34, color: PetTokens.cream),
                    children: [
                      const TextSpan(text: 'Únete a la\n'),
                      TextSpan(
                        text: 'manada',
                        style: PetTokens.display(
                          34,
                          color: PetTokens.clayOnDark,
                          italic: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ayuda a que más mascotas vuelvan a casa.',
                  style: PetTokens.body(14, color: PetTokens.lilacText),
                ),
              ],
            ),
          ),

          // Mascota con inclinación de cabeza
          Positioned(
            right: 16,
            bottom: 8,
            child: ReactivePetAvatar(
              size: 130,
              tiltHead: true,
              coverEyes: coverEyes,
              peeking: peeking,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterHeaderPainter extends CustomPainter {
  const _RegisterHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // M0 0H390V210Q290 262 190 236T0 230Z
    final hill = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.80)
      ..quadraticBezierTo(w * 0.74, h * 1.0, w * 0.49, h * 0.90)
      ..quadraticBezierTo(w * 0.24, h * 0.80, 0, h * 0.88)
      ..close();

    canvas.drawPath(hill, Paint()..color = PetTokens.plum);

    final linePaint = Paint()
      ..color = PetTokens.plumLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final dy in [0.42, 0.58]) {
      final p = Path()
        ..moveTo(-20, h * dy)
        ..quadraticBezierTo(w * 0.35, h * (dy - 0.2), w * 0.55, h * dy)
        ..quadraticBezierTo(w * 0.85, h * (dy + 0.2), w + 20, h * dy);
      canvas.drawPath(p, linePaint);
    }
  }

  @override
  bool shouldRepaint(_RegisterHeaderPainter oldDelegate) => false;
}

/// Medidor de fortaleza de contraseña con 4 huellitas del diseño
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    final int level;
    final String label;

    if (length == 0) {
      level = 0;
      label = 'Fuerza de la contraseña';
    } else if (length < 4) {
      level = 1;
      label = 'Débil';
    } else if (length < 7) {
      level = 2;
      label = 'Regular';
    } else if (length < 10) {
      level = 3;
      label = 'Buena';
    } else {
      level = 4;
      label = 'Muy fuerte';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          for (var i = 1; i <= 4; i++) ...[
            PetPaw(
              size: 18,
              color: i <= level ? PetTokens.clay : PetTokens.trackOf(context),
            ),
            if (i < 4) const SizedBox(width: 8),
          ],
          const SizedBox(width: 12),
          Text(
            label,
            style: PetTokens.body(
              13,
              color: level == 0
                  ? PetTokens.muted2
                  : (level == 1
                      ? PetTokens.lostTextOf(context)
                      : (level == 4 ? PetTokens.mintTextOf(context) : PetTokens.mutedOf(context))),
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({
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
        borderRadius: BorderRadius.circular(PetTokens.rButton),
        boxShadow: PetTokens.shadowButton,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PetTokens.plum,
          foregroundColor: Colors.white,
          disabledBackgroundColor: PetTokens.plum.withValues(alpha: 0.6),
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
