import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/pet_tokens.dart';
import '../providers/auth_provider.dart';
import 'widgets/reactive_pet_avatar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _coverEyes = false;
  bool _peeking = false;

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(_onPasswordFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onPasswordFocusChange() {
    setState(() {
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

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _codeSent = true;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.authResetCodeSent)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(apiErrorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.authResetSuccess)));
      context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(apiErrorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header curvo con avatar
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PetTokens.isDark(context)
                    ? const Color(0xFF2E1C2E)
                    : PetTokens.plum,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: top + 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => context.pop(),
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
                  Positioned(
                    left: 24,
                    bottom: 24,
                    right: 170,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.authForgotPasswordTitle,
                          style: PetTokens.display(26, color: PetTokens.cream),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.authForgotPasswordSubtitle,
                          style: PetTokens.body(
                            13,
                            color: const Color(0xFFD9C8D3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 16,
                    child: ReactivePetAvatar(
                      size: 130,
                      coverEyes: _coverEyes,
                      peeking: _peeking,
                    ),
                  ),
                ],
              ),
            ),

            // Formulario
            Padding(
              padding: const EdgeInsets.all(PetTokens.gutter),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // Campo Correo
                    Text(
                      l10n.authEmail,
                      style: PetTokens.body(13,
                          color: PetTokens.inkOf(context),
                          weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      enabled: !_codeSent,
                      keyboardType: TextInputType.emailAddress,
                      style: PetTokens.bodyThemed(context, 16,
                          color: PetTokens.inkOf(context)),
                      decoration: InputDecoration(
                        hintText: l10n.authEmailHint,
                        hintStyle: PetTokens.body(16,
                            color: PetTokens.mutedOf(context)),
                        prefixIcon: const Icon(Icons.mail_outline_rounded,
                            size: 20, color: PetTokens.muted2),
                        filled: true,
                        fillColor: PetTokens.surfaceHigherOf(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PetTokens.rInput),
                          borderSide: BorderSide(
                              color: PetTokens.borderOf(context), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.authEmailRequired;
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return l10n.authEmailInvalid;
                        }
                        return null;
                      },
                    ),

                    if (!_codeSent) ...[
                      const SizedBox(height: 24),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(PetTokens.rButton),
                          boxShadow: PetTokens.shadowButton,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PetTokens.isDark(context)
                                ? PetTokens.clay
                                : PetTokens.plum,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(PetTokens.rButton),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  l10n.authSendResetCode,
                                  style: PetTokens.body(16,
                                      color: Colors.white,
                                      weight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 18),
                      // Campo Código
                      Text(
                        l10n.authResetCodeLabel,
                        style: PetTokens.body(13,
                            color: PetTokens.inkOf(context),
                            weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        focusNode: _codeFocus,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: PetTokens.bodyThemed(context, 20,
                            color: PetTokens.inkOf(context),
                            weight: FontWeight.w800,
                            letterSpacing: 4),
                        decoration: InputDecoration(
                          hintText: l10n.authResetCodeHint,
                          hintStyle: PetTokens.body(20,
                              color: PetTokens.placeholder,
                              weight: FontWeight.w700,
                              letterSpacing: 4),
                          prefixIcon: const Icon(Icons.key_rounded,
                              size: 20, color: PetTokens.muted2),
                          filled: true,
                          fillColor: PetTokens.surfaceHigherOf(context),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(PetTokens.rInput),
                            borderSide: BorderSide(
                                color: PetTokens.borderOf(context), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 6) {
                            return 'Ingresa los 6 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Campo Nueva Contraseña
                      Text(
                        l10n.authNewPasswordLabel,
                        style: PetTokens.body(13,
                            color: PetTokens.inkOf(context),
                            weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _newPasswordController,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        style: PetTokens.bodyThemed(context, 16,
                            color: PetTokens.inkOf(context)),
                        decoration: InputDecoration(
                          hintText: l10n.authNewPasswordHint,
                          hintStyle: PetTokens.body(16,
                              color: PetTokens.mutedOf(context)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 20, color: PetTokens.muted2),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: PetTokens.muted2,
                              size: 20,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          filled: true,
                          fillColor: PetTokens.surfaceHigherOf(context),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(PetTokens.rInput),
                            borderSide: BorderSide(
                                color: PetTokens.borderOf(context), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 8) {
                            return l10n.authPasswordMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(PetTokens.rButton),
                          boxShadow: PetTokens.shadowButton,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PetTokens.isDark(context)
                                ? PetTokens.clay
                                : PetTokens.plum,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(PetTokens.rButton),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  l10n.authResetPasswordButton,
                                  style: PetTokens.body(16,
                                      color: Colors.white,
                                      weight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n.authBackToLogin,
                        style: PetTokens.body(15,
                            color: PetTokens.lostTextOf(context),
                            weight: FontWeight.w700),
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
  }
}
