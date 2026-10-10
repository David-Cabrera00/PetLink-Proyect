import 'package:flutter/material.dart';

import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_theme_extension.dart';

enum PetButtonVariant {
  primary,
  secondary,
  accent,
  outline,
  lightOutline,
  danger,
}

class PetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PetButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final String? semanticLabel;

  const PetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PetButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extension = PetThemeExtension.of(context);

    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
    );

    final outlineStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: PetRadius.lgAll,
        side: BorderSide(color: cs.primary, width: 1.5),
      ),
    );

    Widget button = switch (variant) {
      PetButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: _buildContent(cs.onPrimary),
      ),
      PetButtonVariant.secondary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(cs.primaryContainer),
          foregroundColor: WidgetStatePropertyAll(cs.onPrimaryContainer),
        ),
        child: _buildContent(cs.onPrimaryContainer),
      ),
      PetButtonVariant.accent => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(extension.accent),
          foregroundColor: WidgetStatePropertyAll(cs.onSurface),
        ),
        child: _buildContent(cs.onSurface),
      ),
      PetButtonVariant.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: outlineStyle,
        child: _buildContent(cs.primary),
      ),
      PetButtonVariant.lightOutline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: outlineStyle.copyWith(
          foregroundColor: WidgetStatePropertyAll(cs.onPrimary),
          side: WidgetStatePropertyAll(
            BorderSide(color: cs.onPrimary.withValues(alpha: 0.72), width: 1.2),
          ),
        ),
        child: _buildContent(cs.onPrimary),
      ),
      PetButtonVariant.danger => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(extension.lost),
          foregroundColor: WidgetStatePropertyAll(cs.onError),
        ),
        child: _buildContent(cs.onError),
      ),
    };

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null && !isLoading,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: textColor),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
