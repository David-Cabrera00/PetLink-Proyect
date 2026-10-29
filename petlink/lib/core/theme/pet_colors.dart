import 'package:flutter/material.dart';

class PetColors {
  PetColors._();

  // Light Theme
  static const Color backgroundLight = Color(0xFFF6EFE8); // sand
  static const Color surfaceLight = Color(0xFFFFFCF9); // surface
  static const Color surfaceVariantLight = Color(0xFFEFE3EC); // lilacBg
  static const Color textPrimaryLight = Color(0xFF2A1A29); // ink
  static const Color textSecondaryLight = Color(0xFF6E5C67); // muted
  static const Color borderLight = Color(0xFFEADFD6); // border

  // Dark Theme
  static const Color backgroundDark = Color(0xFF121016);
  static const Color surfaceDark = Color(0xFF1C1821);
  static const Color surfaceContainerHighestDark = Color(0xFF28202C);
  static const Color textPrimaryDark = Color(0xFFF7F1F4);
  static const Color textSecondaryDark = Color(0xFFB9ABB8);
  static const Color borderDark = Color(0xFF433747);

  // Primary (same for both, adjust if needed)
  static const Color primary = Color(0xFF4A2D4A); // plum
  static const Color primaryLight = Color(0xFFC9A3C1);
  static const Color primaryDark = Color(0xFF2F1E2C);
  static const Color primarySoftLight = Color(0xFFE8DCE7);
  static const Color primarySoftDark = Color(0xFF4B354A);

  // Accent
  static const Color accentLight = Color(0xFFE07A5F); // clay
  static const Color accentDark = Color(0xFFF0A083);

  // Lost
  static const Color lostLight = Color(0xFFB4472F); // clayText
  static const Color lostSoftLight = Color(0xFFFCEEE8); // lostBg
  static const Color lostDark = Color(0xFFE58E98);
  static const Color lostSoftDark = Color(0xFF4A252D);

  // Found
  static const Color foundLight = Color(0xFF2C7A69); // mint
  static const Color foundSoftLight = Color(0xFFDDEFE9); // mintBg
  static const Color foundDark = Color(0xFFA9BDD0);
  static const Color foundSoftDark = Color(0xFF2A3746);

  // Match
  static const Color matchLight = Color(0xFF8A6386);
  static const Color matchSoftLight = Color(0xFFE8DCE7);
  static const Color matchDark = Color(0xFFC6A8C3);
  static const Color matchSoftDark = Color(0xFF443344);

  // Legacy aliases (Light)
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color border = borderLight;
  static const Color primarySoft = primarySoftLight;
  static const Color lost = lostLight;
  static const Color lostSoft = lostSoftLight;
  static const Color found = foundLight;
  static const Color foundSoft = foundSoftLight;
  static const Color match = matchLight;
  static const Color matchSoft = matchSoftLight;
  static const Color accent = accentLight;
}
