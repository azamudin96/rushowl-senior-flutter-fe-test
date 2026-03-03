import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFFFD600); // RushTrail yellow
  static const backgroundDark = Color(0xFF1A1A1A); // Dark charcoal
  static const surfaceDark = Color(0xFF2A2A2A);
  static const borderDark = Color(0xFF3D3D3D);
}

class AppTheme {
  static ThemeData get dark {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFCBD5E1)),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.backgroundDark,
        onSurface: Color(0xFFF1F5F9),
      ),
    );
  }
}
