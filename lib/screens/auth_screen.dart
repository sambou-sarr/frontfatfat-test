// ------------------------------
// IMPORTS
// ------------------------------

// Librairie principale Flutter (UI, widgets, navigation, etc.)
import 'package:flutter/material.dart';

// Police Google (Poppins)
import 'package:google_fonts/google_fonts.dart';

// Icônes FontAwesome (Google icon)
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Tes couleurs/thèmes personnalisés
import '../themes/app_theme.dart';

// Ton logo personnalisé
import '../widgets/fat_fat_logo.dart';

// Ton service API (connexion Laravel)
import '../service/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------------------
// PAGE DE CONNEXION
// ------------------------------

// ⚠️ StatefulWidget car on gère :
// - champs de formulaire
// - chargement (loading)
// - appel API
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// ------------------------------
// STATE (logique de la page)
// ------------------------------
class _AuthScreenState extends State<AuthScreen> {
  // Controllers = récupérer ce que l’utilisateur tape
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Pour afficher un loader pendant l’appel API
  bool isLoading = false;

  // ------------------------------
  // FONCTION DE CONNEXION (API)
  // ------------------------------

  Future<void> login() async {
    // On active le loading
    setState(() {
      isLoading = true;
    });

    // Appel de l’API Laravel
    final result = await Api.login(
      phoneController.text,
      passwordController.text,
    );

    // On désactive le loading
    setState(() {
      isLoading = false;
    });
    print("Code Statut : ${result['status']}");
    print("Réponse du serveur : ${result['body']}");
    print("------------------------------");
    // Si succès (HTTP 200)
    // ... (code précédent)
    if (result['status'] == 200) {
      String token = result['body']['access_token'];

      // 1. Récupérer le rôle depuis la réponse API
      // Note : Adaptez 'role' selon la structure exacte de votre JSON Laravel
      String role = result['body']['user']['role'];

      // 2. Sauvegarder le token et éventuellement le rôle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);

      if (!mounted) return;

      // 3. Redirection conditionnelle
      if (role == 'livreur') {
        Navigator.pushReplacementNamed(context, '/driver_home');
      } else {
        Navigator.pushReplacementNamed(context, '/client_home');
      }
    }
    // ... (reste du code)
    else {
      // Échec : on affiche le message d'erreur de Laravel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['body']['message'] ?? "Erreur de connexion"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------
  // UI (INTERFACE)
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre du haut (vide ici)
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),

      // Corps de la page
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        // Colonne verticale
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // Logo
            const Center(child: FatFatLogo(size: 50)),

            const SizedBox(height: 40),

            // Titre
            Text(
              "Bienvenue !",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Sous-titre
            Text(
              "Connectez-vous pour continuer",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // ------------------------------
            // CHAMP TÉLÉPHONE
            // ------------------------------
            TextFormField(
              controller: phoneController, // 👈 récupère la valeur
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // CHAMP MOT DE PASSE
            // ------------------------------
            TextFormField(
              controller: passwordController, // 👈 récupère la valeur
              obscureText: true, // cache le mot de passe
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            // Mot de passe oublié
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Mot de passe oublié ?"),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // BOUTON CONNEXION
            // ------------------------------
            ElevatedButton(
              onPressed: isLoading ? null : login, // 👈 appel API
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Connexion"),
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // CONNEXION GOOGLE (UI seulement)
            // ------------------------------
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(FontAwesomeIcons.google, color: Colors.red),
              label: const Text(
                "Continuer avec Google",
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ),

            const SizedBox(height: 40),

            // ------------------------------
            // LIEN INSCRIPTION
            // ------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Pas encore de compte ?"),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "S'inscrire",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
