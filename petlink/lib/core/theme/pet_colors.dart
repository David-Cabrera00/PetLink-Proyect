import 'package:flutter/material.dart';

class PetColors {
  PetColors._();

  // Light Theme
  static const Color backgroundLight = Color(0xFFF6F8F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEEF3F1);
  static const Color textPrimaryLight = Color(0xFF152323);
  static const Color textSecondaryLight = Color(0xFF5F6F70);
  static const Color borderLight = Color(0xFFD9E0DF);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF0E1515);
  static const Color surfaceDark = Color(0xFF162020);
  static const Color surfaceContainerHighestDark = Color(0xFF1D2A2A);
  static const Color textPrimaryDark = Color(0xFFF2F6F5);
  static const Color textSecondaryDark = Color(0xFFAAB8B7);
  static const Color borderDark = Color(0xFF30403F);

  // Primary (same for both, adjust if needed)
  static const Color primary = Color(0xFF0F6B6F);
  static const Color primaryDark = Color(0xFF0B5558);
  static const Color primarySoftLight = Color(0xFFD8EFEA);
  static const Color primarySoftDark = Color(0xFF173C3D);

  // Accent
  static const Color accentLight = Color(0xFFF4A261);
  static const Color accentDark = Color(0xFFF5B375);

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
