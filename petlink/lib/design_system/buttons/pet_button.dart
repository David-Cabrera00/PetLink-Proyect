import 'package:flutter/material.dart';
import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';

enum PetButtonVariant { primary, secondary, outline, danger }

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
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: PetSpacing.md, horizontal: PetSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final outlineStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(vertical: PetSpacing.md, horizontal: PetSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: PetColors.primary, width: 1.5),
      ),
    );

    Widget button = switch (variant) {
      PetButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: _buildContent(PetColors.surface),
        ),
      PetButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll(PetColors.primarySoft),
            foregroundColor: WidgetStatePropertyAll(PetColors.primaryDark),
          ),
          child: _buildContent(PetColors.primaryDark),
        ),
      PetButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: outlineStyle,
          child: _buildContent(PetColors.primary),
        ),
      PetButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll(PetColors.lost),
            foregroundColor: WidgetStatePropertyAll(PetColors.surface),
          ),
          child: _buildContent(PetColors.surface),
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
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: textColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: PetSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
