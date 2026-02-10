import 'package:flutter/material.dart';

class AppColors {
  // Définition des couleurs principales
  static const Color primaryRed = Color(0xFFE53935); // Rouge principal
  static const Color primaryYellow = Color(0xFFFFC107); // Jaune principal
  static const Color darkGrey = Color(0xFF333333); // Gris foncé pour le texte
  static const Color lightGrey = Color(0xFFF5F5F5); // Gris clair pour les fonds
  static const Color white = Color(0xFFFFFFFF); // Blanc

  // Définition des gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryRed, primaryYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
