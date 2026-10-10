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
    lost: Color(0xFFC2414B),
    lostSoft: Color(0xFFFDE7E4),
    found: Color(0xFF2D7A5F),
    foundSoft: Color(0xFFE8F3ED),
    match: Color(0xFF6257B8),
    matchSoft: Color(0xFFEAE7FA),
    accent: Color(0xFFE9825B),
    surfaceVariant: Color(0xFFEEF3F1),
  );

  static const PetThemeExtension dark = PetThemeExtension(
    lost: Color(0xFFF1787F),
    lostSoft: Color(0xFF422326),
    found: Color(0xFF64C49B),
    foundSoft: Color(0xFF19382D),
    match: Color(0xFF9C92E8),
    matchSoft: Color(0xFF2E294B),
    accent: Color(0xFFF2A07A),
    surfaceVariant: Color(0xFF1D2A2A),
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
