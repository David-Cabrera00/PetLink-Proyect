import 'package:flutter/material.dart';

class PetThemeExtension extends ThemeExtension<PetThemeExtension> {
  const PetThemeExtension({
    required this.lost,
    required this.lostSoft,
    required this.found,
    required this.foundSoft,
    required this.match,
    required this.matchSoft,
    required this.accent,
    required this.surfaceVariant,
  });

  final Color lost;
  final Color lostSoft;
  final Color found;
  final Color foundSoft;
  final Color match;
  final Color matchSoft;
  final Color accent;
  final Color surfaceVariant;

  static const PetThemeExtension light = PetThemeExtension(
    lost: Color(0xFFB4472F),
    lostSoft: Color(0xFFFCEEE8),
    found: Color(0xFF2C7A69),
    foundSoft: Color(0xFFDDEFE9),
    match: Color(0xFF8A6386),
    matchSoft: Color(0xFFE8DCE7),
    accent: Color(0xFFE07A5F),
    surfaceVariant: Color(0xFFEFE3EC),
  );

  static const PetThemeExtension dark = PetThemeExtension(
    lost: Color(0xFFFF9E84),
    lostSoft: Color(0x33E07A5F),
    found: Color(0xFF5CD6A5),
    foundSoft: Color(0x2E4B8B73),
    match: Color(0xFFD8AED6),
    matchSoft: Color(0xFF382338),
    accent: Color(0xFFFF9E84),
    surfaceVariant: Color(0xFF28212F),
  );

  static PetThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<PetThemeExtension>()!;
  }

  @override
  PetThemeExtension copyWith({
    Color? lost,
    Color? lostSoft,
    Color? found,
    Color? foundSoft,
    Color? match,
    Color? matchSoft,
    Color? accent,
    Color? surfaceVariant,
  }) {
    return PetThemeExtension(
      lost: lost ?? this.lost,
      lostSoft: lostSoft ?? this.lostSoft,
      found: found ?? this.found,
      foundSoft: foundSoft ?? this.foundSoft,
      match: match ?? this.match,
      matchSoft: matchSoft ?? this.matchSoft,
      accent: accent ?? this.accent,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    );
  }

  @override
  PetThemeExtension lerp(ThemeExtension<PetThemeExtension>? other, double t) {
    if (other is! PetThemeExtension) return this;
    return PetThemeExtension(
      lost: Color.lerp(lost, other.lost, t)!,
      lostSoft: Color.lerp(lostSoft, other.lostSoft, t)!,
      found: Color.lerp(found, other.found, t)!,
      foundSoft: Color.lerp(foundSoft, other.foundSoft, t)!,
      match: Color.lerp(match, other.match, t)!,
      matchSoft: Color.lerp(matchSoft, other.matchSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
    );
  }
}
