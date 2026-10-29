import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens del rediseño (fuente: tokens.json del paquete de diseño).
class PetTokens {
  PetTokens._();

  // Colores constantes (Light Palette oficial de tokens.json)
  static const Color plum = Color(0xFF4A2D4A);
  static const Color plumDeep = Color(0xFF2E1B2E);
  static const Color plumLine = Color(0xFF5E3E5E);
  static const Color cream = Color(0xFFFBF6F1);
  static const Color sand = Color(0xFFF6EFE8);
  static const Color surface = Color(0xFFFFFCF9);
  static const Color border = Color(0xFFEADFD6);
  static const Color borderDark = Color(0xFFDCCFC4);
  static const Color track = Color(0xFFE3D6CB);
  static const Color ink = Color(0xFF2A1A29);
  static const Color muted = Color(0xFF6E5C67);
  static const Color muted2 = Color(0xFF7A6872);
  static const Color placeholder = Color(0xFF8E7D87);
  static const Color clay = Color(0xFFE07A5F);
  static const Color clayText = Color(0xFFB4472F);
  static const Color clayOnDark = Color(0xFFF29A7E);
  static const Color pinLost = Color(0xFFC8553D);
  static const Color peach = Color(0xFFF3B79F);
  static const Color lilacText = Color(0xFFD9C8D3);
  static const Color lilacBg = Color(0xFFEFE3EC);
  static const Color mint = Color(0xFF2C7A69);
  static const Color mintText = Color(0xFF23695A);
  static const Color mintBg = Color(0xFFDDEFE9);
  static const Color mintOnDark = Color(0xFF7FCFB9);
  static const Color lostBg = Color(0xFFFCEEE8);

  static const Color bg = sand;
  static const Color card = surface;

  static const Color dogTan = Color(0xFFE8A86B);
  static const Color dogEar = Color(0xFF8A4F2B);
  static const Color dogMuzzle = Color(0xFFFBF0E4);
  static const Color dogDark = Color(0xFFC9844A);
  static const Color tagGold = Color(0xFFF6C760);
  static const Color mapGround = Color(0xFFEFE6DC);
  static const Color mapBlock = Color(0xFFE4D6C8);
  static const Color mapPark = Color(0xFFCFE0C9);
  static const Color mapWater = Color(0xFFC9DDE6);
  static const Color mapRoad = Color(0xFFFFFCF8);

  // Radios
  static const double rChip = 14;
  static const double rInput = 16;
  static const double rButton = 18;
  static const double rCard = 24;
  static const double rCardHero = 28;
  static const double rNav = 26;
  static const double rFab = 20;

  // Layout
  static const double gutter = 20;
  static const double navInset = 14;
  static const double navBottom = 18;
  static const double navHeight = 72;
  static const double contentBottomPadding = 120;

  // Sombras
  static const List<BoxShadow> shadowButton = [
    BoxShadow(
      color: Color(0x474A2D4A),
      offset: Offset(0, 12),
      blurRadius: 26,
    ),
  ];

  static const List<BoxShadow> shadowNav = [
    BoxShadow(
      color: Color(0x244A2D4A),
      offset: Offset(0, 10),
      blurRadius: 30,
    ),
  ];

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x1A2A1A29),
      offset: Offset(0, 12),
      blurRadius: 28,
    ),
  ];

  // Movimiento
  static const Curve rise = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve bounce = Cubic(0.3, 1.5, 0.5, 1);
  static const Curve camera = Cubic(0.45, 0, 0.35, 1);
  static const Duration riseDuration = Duration(milliseconds: 600);
  static const Duration riseStagger = Duration(milliseconds: 70);
  static const Duration dFast = Duration(milliseconds: 200);
  static const Duration dNormal = Duration(milliseconds: 300);

  // Helpers reactivos al modo oscuro según el contexto
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF141117)
          : sand;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1924)
          : surface;

  static Color inkOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF8F2F6)
          : ink;

  static Color mutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFB8AAB7)
          : muted;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B2F3D)
          : border;

  static Color trackOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF332938)
          : track;

  static Color cardOf(BuildContext context) => surfaceOf(context);

  static Color cardSubtleOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF28202C)
          : const Color(0xFFEFE5DC);

  // Tipografía: Fraunces (display) + Manrope (UI)
  static TextStyle display(
    double size, {
    Color color = ink,
    bool italic = false,
    double height = 1.05,
  }) => GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: FontWeight.w500,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    letterSpacing: -size * 0.02,
    height: height,
    color: color,
  );

  static TextStyle displayThemed(
    BuildContext context,
    double size, {
    Color? color,
    bool italic = false,
    double height = 1.05,
  }) => display(
    size,
    color: color ?? inkOf(context),
    italic: italic,
    height: height,
  );

  static TextStyle body(
    double size, {
    Color color = ink,
    FontWeight weight = FontWeight.w500,
    double height = 1.45,
    double? letterSpacing,
  }) => GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
    letterSpacing: letterSpacing,
  );

  static TextStyle bodyThemed(
    BuildContext context,
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.45,
    double? letterSpacing,
  }) => body(
    size,
    color: color ?? inkOf(context),
    weight: weight,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle eyebrow({Color color = muted2}) => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 12 * 0.14,
    color: color,
  );

  /// Título con UNA palabra de acento en Fraunces itálica.
  static TextSpan headline({
    required String before,
    required String accent,
    String after = '',
    required double size,
    Color color = ink,
    Color accentColor = clayText,
  }) {
    final base = display(size, color: color);
    return TextSpan(
      style: base,
      children: [
        TextSpan(text: before),
        TextSpan(
          text: accent,
          style: display(size, color: accentColor, italic: true),
        ),
        if (after.isNotEmpty) TextSpan(text: after),
      ],
    );
  }
}
