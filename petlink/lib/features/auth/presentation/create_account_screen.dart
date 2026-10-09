import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_typography.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/inputs/pet_input.dart';
import '../providers/auth_provider.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(authProvider.notifier)
        .register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (mounted) context.go('/radar');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600
                ? PetSpacing.lg
                : PetSpacing.xxl;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PetSpacing.lg,
                horizontalPadding,
                PetSpacing.xxl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.authRegisterTitle,
                            style: PetTypography.display.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: PetSpacing.xs),
                          Text(
                            l10n.authRegisterDescription,
                            style: PetTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: PetSpacing.xl),
                          PetInput(
                            label: l10n.authName,
                            hint: l10n.authNameHint,
                            controller: _nameController,
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.authNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: PetSpacing.lg),
                          PetInput(
                            label: l10n.authEmail,
                            hint: l10n.authEmailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
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
                          _buildPasswordInput(l10n),
                          const SizedBox(height: PetSpacing.lg),
                          _buildConfirmationInput(l10n),
                          const SizedBox(height: PetSpacing.xl),
                          PetButton(
                            label: l10n.authRegister,
                            isLoading: isLoading,
                            onPressed: _submit,
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
      ),
    );
  }

  Widget _buildPasswordInput(AppLocalizations l10n) {
    return PetInput(
      label: l10n.authPassword,
      hint: l10n.authPasswordHint,
      controller: _passwordController,
      obscureText: _obscurePassword,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        tooltip: l10n.authPasswordVisibility,
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.authPasswordRequired;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmationInput(AppLocalizations l10n) {
    return PetInput(
      label: l10n.authConfirmPassword,
      hint: l10n.authConfirmPasswordHint,
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmation,
      prefixIcon: const Icon(Icons.lock_reset_outlined),
      suffixIcon: IconButton(
        tooltip: l10n.authPasswordVisibility,
        icon: Icon(
          _obscureConfirmation
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() => _obscureConfirmation = !_obscureConfirmation);
        },
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
    );
  }
}
