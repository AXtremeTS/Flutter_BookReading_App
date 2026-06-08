import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBg: AppColors.canvas,
      textColor: AppColors.ink,
      surfaceColor: AppColors.surfaceSoft,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primaryColor: AppColors.canvas,
      scaffoldBg: const Color(0xFF121212),
      textColor: AppColors.canvas,
      surfaceColor: const Color(0xFF1E1E1E),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color scaffoldBg,
    required Color textColor,
    required Color surfaceColor,
  }) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: surfaceColor,
      textTheme: TextTheme(
        // Display XL - 86px
        displayLarge: GoogleFonts.inter(
          fontSize: 86,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: -1.72,
          color: textColor,
        ),
        // Display LG - 64px
        displayMedium: GoogleFonts.inter(
          fontSize: 64,
          fontWeight: FontWeight.w400,
          height: 1.1,
          letterSpacing: -0.96,
          color: textColor,
        ),
        // Headline - 26px
        headlineMedium: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          height: 1.35,
          letterSpacing: -0.26,
          color: textColor,
        ),
        // Subhead - 26px
        headlineSmall: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w400,
          height: 1.35,
          letterSpacing: -0.26,
          color: textColor,
        ),
        // Card Title - 24px
        titleLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.45,
          color: textColor,
        ),
        // Body Large - 20px
        bodyLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: -0.14,
          color: textColor,
        ),
        // Body - 18px
        bodyMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: -0.26,
          color: textColor,
        ),
        // Body Small - 16px
        bodySmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: -0.14,
          color: textColor,
        ),
        // Button - 20px
        labelLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: -0.10,
          color: isDark ? AppColors.ink : AppColors.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.canvas : AppColors.primary,
          foregroundColor: isDark ? AppColors.ink : AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : AppColors.canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3C3C3C) : AppColors.hairline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3C3C3C) : AppColors.hairline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.canvas : AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      iconTheme: IconThemeData(color: textColor),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textColor,
        elevation: 0,
      ),
    );
  }
}

