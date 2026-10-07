import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pet_colors.dart';

class PetTypography {
  PetTypography._();

  static TextStyle get _manrope => GoogleFonts.manrope();

  static TextStyle get display => _manrope.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: PetColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get heading => _manrope.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: PetColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get title => _manrope.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PetColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get body => _manrope.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PetColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => _manrope.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PetColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get label => _manrope.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: PetColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get button => _manrope.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: PetColors.surface,
    height: 1.2,
  );
}
