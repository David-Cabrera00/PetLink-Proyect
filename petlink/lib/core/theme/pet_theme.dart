import 'package:flutter/material.dart';

import 'pet_colors.dart';
import 'pet_typography.dart';
import 'pet_radius.dart';
import 'pet_spacing.dart';

class PetTheme {
  PetTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: PetColors.primary,
        onPrimary: PetColors.surface,
        primaryContainer: PetColors.primarySoft,
        onPrimaryContainer: PetColors.primaryDark,
        secondary: PetColors.accent,
        onSecondary: PetColors.surface,
        surface: PetColors.surface,
        onSurface: PetColors.textPrimary,
        error: PetColors.lost,
        onError: PetColors.surface,
        outline: PetColors.border,
      ),
      scaffoldBackgroundColor: PetColors.background,
      textTheme: TextTheme(
        displaySmall: PetTypography.display,
        headlineMedium: PetTypography.heading,
        titleLarge: PetTypography.title,
        bodyLarge: PetTypography.body,
        bodyMedium: PetTypography.bodySmall,
        bodySmall: PetTypography.label,
        labelLarge: PetTypography.button,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PetColors.surface,
        foregroundColor: PetColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PetColors.primary,
          foregroundColor: PetColors.surface,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
          textStyle: PetTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PetColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: PetColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
          textStyle: PetTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PetColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PetSpacing.lg,
          vertical: PetSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.lost),
        ),
      ),
      cardTheme: CardThemeData(
        color: PetColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: PetRadius.xlAll,
          side: const BorderSide(color: PetColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PetColors.surface,
        selectedItemColor: PetColors.primary,
        unselectedItemColor: PetColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
