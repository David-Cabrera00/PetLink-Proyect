import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_spacing.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/inputs/pet_input.dart';
import 'widgets/petlink_brand_mark.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _instructionsSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInstructions() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _instructionsSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('PetLink'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
                PetSpacing.xl,
                horizontalPadding,
                PetSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PetLinkBrandMark(),
                        const SizedBox(height: PetSpacing.md),
                        Text(
                          l10n.authForgotPasswordTitle,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          l10n.authForgotPasswordDescription,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: PetSpacing.xxl),
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
                        PetButton(
                          label: l10n.authSendInstructions,
                          onPressed: _sendInstructions,
                        ),
                        if (_instructionsSent) ...[
                          const SizedBox(height: PetSpacing.lg),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(PetSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: PetSpacing.sm),
                                Expanded(
                                  child: Text(
                                    l10n.authForgotPasswordConfirmation,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
}
