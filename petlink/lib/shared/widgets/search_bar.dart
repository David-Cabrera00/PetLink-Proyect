import 'package:flutter/material.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';

class PetSearchBar extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const PetSearchBar({super.key, this.hint, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: PetColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint ?? 'Buscar mascota o zona',
          hintStyle: TextStyle(color: PetColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: PetColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: PetSpacing.lg,
            vertical: PetSpacing.md,
          ),
        ),
      ),
    );
  }
}
