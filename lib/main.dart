import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/client_history_screen.dart'; // Ajout de l'importation
import 'themes/app_theme.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/client_profile_screen.dart';

// Importation des fichiers pour l'historique
//import 'screens/client_history_screen.dart'; // Import de l'écran d'historique
//import 'models/history_model.dart';    // Import du modèle d'historique
//import 'widgets/history_card.dart';    // Import de la carte d'historique

void main() {
  runApp(const FatFatApp());
}

class FatFatApp extends StatelessWidget {
  const FatFatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAT FAT Sénégal',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/signup': (context) => const SignupScreen(),
        '/client_home': (context) => const ClientMainScreen(),
        '/driver_home': (context) => const DriverMainScreen(),
        '/client_history': (context) => ClientHistoryScreen(),
        '/driver_profile': (context) => const DriverProfileScreen(),
        '/client_profile': (context) => const ClientProfileScreen(userName: ""),
      },
    );
  }
}
