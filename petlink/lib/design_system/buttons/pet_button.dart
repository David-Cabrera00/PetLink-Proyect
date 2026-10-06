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

  const PetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PetButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      PetButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildContent(PetColors.surface),
        ),
      PetButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: PetColors.primarySoft,
            foregroundColor: PetColors.primaryDark,
          ),
          child: _buildContent(PetColors.primaryDark),
        ),
      PetButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildContent(PetColors.primary),
        ),
      PetButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: PetColors.lost,
            foregroundColor: PetColors.surface,
          ),
          child: _buildContent(PetColors.surface),
        ),
    };
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
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
