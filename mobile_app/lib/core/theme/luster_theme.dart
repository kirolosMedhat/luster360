import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'luster_colors.dart';
import 'luster_typography.dart';

class LusterTheme {
  LusterTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LusterColors.background,
      primaryColor: LusterColors.primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: LusterColors.primaryBlue,
        onPrimary: LusterColors.darkNavy,
        secondary: LusterColors.header,
        onSecondary: LusterColors.text,
        surface: LusterColors.surface,
        onSurface: LusterColors.text,
        error: LusterColors.danger,
        onError: LusterColors.pureWhite,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: LusterColors.panel,
        foregroundColor: LusterColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: LusterTypography.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: LusterColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: LusterColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LusterColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LusterColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LusterColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LusterColors.primaryBlue, width: 1.5),
        ),
        labelStyle: LusterTypography.bodyMedium,
        hintStyle: LusterTypography.bodySmall,
      ),
      dividerTheme: const DividerThemeData(
        color: LusterColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
