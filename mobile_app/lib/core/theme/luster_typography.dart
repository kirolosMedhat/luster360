import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'luster_colors.dart';

class LusterTypography {
  LusterTypography._();

  static TextStyle get heroCountdown => GoogleFonts.inter(
        fontSize: 120,
        fontWeight: FontWeight.w900,
        color: LusterColors.primaryBlue,
        letterSpacing: -2.0,
      );

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: LusterColors.text,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: LusterColors.text,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: LusterColors.text,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: LusterColors.text,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: LusterColors.text,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: LusterColors.textMuted,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: LusterColors.textDark,
      );

  static TextStyle get monoTimer => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: LusterColors.primaryBlue,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: LusterColors.darkNavy,
        letterSpacing: 0.2,
      );
}
