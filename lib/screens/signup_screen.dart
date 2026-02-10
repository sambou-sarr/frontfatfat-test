import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../themes/app_theme.dart'; // Assurez-vous que ce fichier existe
import '../service/api.dart'; // Import du fichier créé ci-dessus

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // État du formulaire
  String _selectedProfile = 'Client';
  bool isLoading = false;

  // Contrôleurs
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Nettoyage de la mémoire
  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    phoneController.dispose();
    plateController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- LOGIQUE D'INSCRIPTION ---
  Future<void> register() async {
    // 1. Vérification basique
    if (nomController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires."),
        ),
      );
      return;
    }

    // 2. Activation du chargement
    setState(() => isLoading = true);

    // 3. Préparation des données
    Map<String, dynamic> data = {
      'nom': nomController.text.trim(),
      'prenom': prenomController.text.trim(),
      'telephone': phoneController.text.trim(),
      'password': passwordController.text,
      'role': _selectedProfile.toLowerCase(), // 'client' ou 'livreur'
    };

    // Ajout de la plaque uniquement si c'est un livreur
    if (_selectedProfile == 'Livreur') {
      data['numero_plaque'] = plateController.text.trim();
    }

    // 4. Appel API
    final result = await Api.register(data);

    // 5. Désactivation du chargement
    setState(() => isLoading = false);

    // 6. Gestion du résultat
    if (!mounted) return;

    if (result['status'] == 201 || result['status'] == 200) {
      // SUCCÈS
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès !"),
          backgroundColor: Colors.green,
        ),
      );

      // Redirection selon le profil
      if (_selectedProfile == 'Livreur') {
        Navigator.pushReplacementNamed(context, '/driver_home');
      } else {
        Navigator.pushReplacementNamed(context, '/client_home');
      }
    } else {
      // ERREUR (ex: téléphone déjà pris)
      String errorMessage =
          result['body']['message'] ?? "Une erreur est survenue.";

      // Si Laravel renvoie des erreurs de validation détaillées
      if (result['body']['errors'] != null) {
        errorMessage = result['body']['errors'].values.first[0];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  // --- INTERFACE GRAPHIQUE ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Choisissez votre profil",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Sélecteur de profil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileOption('Client', Icons.person),
                _buildProfileOption('Livreur', FontAwesomeIcons.motorcycle),
              ],
            ),
            const SizedBox(height: 30),

            // Champs de texte
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 20),

            // Champ conditionnel (Plaque)
            if (_selectedProfile == 'Livreur') ...[
              TextFormField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Numéro Plaque / Moto',
                  prefixIcon: Icon(Icons.motorcycle),
                ),
              ),
              const SizedBox(height: 20),
            ],

            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 40),

            // Bouton d'inscription
            ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Créer mon compte",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personnalisé pour les boutons de choix (Client/Livreur)
  Widget _buildProfileOption(String label, IconData icon) {
    bool isSelected = _selectedProfile == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedProfile = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.darkGrey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
