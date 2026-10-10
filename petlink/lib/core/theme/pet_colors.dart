import 'package:flutter/material.dart';

class PetColors {
  PetColors._();

  // Light Theme
  static const Color backgroundLight = Color(0xFFF4F1EB);
  static const Color surfaceLight = Color(0xFFFFFDFA);
  static const Color surfaceVariantLight = Color(0xFFE9E4DA);
  static const Color textPrimaryLight = Color(0xFF172B32);
  static const Color textSecondaryLight = Color(0xFF637176);
  static const Color borderLight = Color(0xFFD8D4CC);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF101A1D);
  static const Color surfaceDark = Color(0xFF17262A);
  static const Color surfaceContainerHighestDark = Color(0xFF223438);
  static const Color textPrimaryDark = Color(0xFFF5F0E8);
  static const Color textSecondaryDark = Color(0xFFB8C0BF);
  static const Color borderDark = Color(0xFF3A4B4F);

  // Primary (same for both, adjust if needed)
  static const Color primary = Color(0xFF164D59);
  static const Color primaryDark = Color(0xFF103943);
  static const Color primarySoftLight = Color(0xFFD8E8E6);
  static const Color primarySoftDark = Color(0xFF1E4148);

  // Accent
  static const Color accentLight = Color(0xFFE9825B);
  static const Color accentDark = Color(0xFFD1B07A);

  // Lost
  static const Color lostLight = Color(0xFFC2414B);
  static const Color lostSoftLight = Color(0xFFFDE7E4);
  static const Color lostDark = Color(0xFFF1787F);
  static const Color lostSoftDark = Color(0xFF422326);

  // Found
  static const Color foundLight = Color(0xFF2D7A5F);
  static const Color foundSoftLight = Color(0xFFE8F3ED);
  static const Color foundDark = Color(0xFF64C49B);
  static const Color foundSoftDark = Color(0xFF19382D);

  // Match
  static const Color matchLight = Color(0xFF6257B8);
  static const Color matchSoftLight = Color(0xFFEAE7FA);
  static const Color matchDark = Color(0xFF9C92E8);
  static const Color matchSoftDark = Color(0xFF2E294B);

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
