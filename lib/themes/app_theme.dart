import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color darkGrey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryRed, primaryYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightGrey,
    primaryColor: AppColors.primaryRed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryRed,
      primary: AppColors.primaryRed,
      secondary: AppColors.primaryYellow,
      surface: AppColors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.darkGrey,
      displayColor: AppColors.darkGrey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkGrey),
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkGrey,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
