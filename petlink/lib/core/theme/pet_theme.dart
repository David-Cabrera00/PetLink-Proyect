import 'package:flutter/material.dart';

import 'pet_colors.dart';
import 'pet_typography.dart';
import 'pet_radius.dart';
import 'pet_spacing.dart';
import 'pet_theme_extension.dart';

class PetTheme {
  PetTheme._();

  static ThemeData get light {
    final extension = PetThemeExtension.light;
    return ThemeData(
      useMaterial3: true,
      extensions: [extension],
      colorScheme: ColorScheme.light(
        primary: PetColors.primary,
        onPrimary: PetColors.surfaceLight,
        primaryContainer: PetColors.primarySoftLight,
        onPrimaryContainer: PetColors.primaryDark,
        secondary: PetColors.accentLight,
        onSecondary: PetColors.surfaceLight,
        surface: PetColors.surfaceLight,
        onSurface: PetColors.textPrimaryLight,
        surfaceContainerHighest: extension.surfaceVariant,
        onSurfaceVariant: PetColors.textSecondaryLight,
        error: PetColors.lostLight,
        onError: PetColors.surfaceLight,
        outline: PetColors.borderLight,
      ),
      scaffoldBackgroundColor: PetColors.backgroundLight,
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
        backgroundColor: PetColors.surfaceLight,
        foregroundColor: PetColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PetColors.primary,
          foregroundColor: PetColors.surfaceLight,
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
        fillColor: PetColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PetSpacing.lg,
          vertical: PetSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.lostLight),
        ),
      ),
      cardTheme: CardThemeData(
        color: PetColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: PetRadius.xlAll,
          side: const BorderSide(color: PetColors.borderLight),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PetColors.surfaceLight,
        selectedItemColor: PetColors.primary,
        unselectedItemColor: PetColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get dark {
    final extension = PetThemeExtension.dark;
    return ThemeData(
      useMaterial3: true,
      extensions: [extension],
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF54B8B5),
        onPrimary: PetColors.surfaceDark,
        primaryContainer: PetColors.primarySoftDark,
        onPrimaryContainer: PetColors.primarySoftLight,
        secondary: PetColors.accentDark,
        onSecondary: PetColors.surfaceDark,
        surface: PetColors.surfaceDark,
        onSurface: PetColors.textPrimaryDark,
        surfaceContainerHighest: extension.surfaceVariant,
        onSurfaceVariant: PetColors.textSecondaryDark,
        error: extension.lost,
        onError: PetColors.surfaceDark,
        outline: PetColors.borderDark,
      ),
      scaffoldBackgroundColor: PetColors.backgroundDark,
      textTheme: TextTheme(
        displaySmall: PetTypography.display.copyWith(
          color: PetColors.textPrimaryDark,
        ),
        headlineMedium: PetTypography.heading.copyWith(
          color: PetColors.textPrimaryDark,
        ),
        titleLarge: PetTypography.title.copyWith(
          color: PetColors.textPrimaryDark,
        ),
        bodyLarge: PetTypography.body.copyWith(
          color: PetColors.textPrimaryDark,
        ),
        bodyMedium: PetTypography.bodySmall.copyWith(
          color: PetColors.textSecondaryDark,
        ),
        bodySmall: PetTypography.label.copyWith(
          color: PetColors.textSecondaryDark,
        ),
        labelLarge: PetTypography.button.copyWith(color: PetColors.surfaceDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PetColors.surfaceDark,
        foregroundColor: PetColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF54B8B5),
          foregroundColor: PetColors.surfaceDark,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
          textStyle: PetTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF54B8B5),
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: Color(0xFF54B8B5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
          textStyle: PetTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PetColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PetSpacing.lg,
          vertical: PetSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: Color(0xFF54B8B5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: PetRadius.lgAll,
          borderSide: const BorderSide(color: PetColors.lostDark),
        ),
      ),
      cardTheme: CardThemeData(
        color: PetColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: PetRadius.xlAll,
          side: const BorderSide(color: PetColors.borderDark),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PetColors.surfaceDark,
        selectedItemColor: Color(0xFF54B8B5),
        unselectedItemColor: PetColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
