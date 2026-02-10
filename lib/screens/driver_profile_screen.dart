import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header: Photo et Info de base
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryYellow,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 15),
          Text(
            "Modou Diop", // Dynamique via API plus tard
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Livreur Certifié - Dakar",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 25),

          // Statistiques rapides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Note", "4.8", Icons.star, Colors.orange),
              _buildStatCard(
                "Livraisons",
                "124",
                Icons.local_shipping,
                Colors.blue,
              ),
              _buildStatCard("Annulation", "2%", Icons.cancel, Colors.red),
            ],
          ),
          const SizedBox(height: 30),

          // Menu des options
          _buildMenuTile(
            Icons.directions_car,
            "Mon Véhicule",
            "Moto - ABC-123-XY",
          ),
          _buildMenuTile(
            Icons.account_balance_wallet,
            "Informations de Paiement",
            "Wave / Orange Money",
          ),
          _buildMenuTile(Icons.history, "Historique des courses", ""),
          _buildMenuTile(
            Icons.security,
            "Documents Légaux",
            "Permis, Assurance",
          ),

          const Divider(height: 40),

          // Bouton Déconnexion
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Logique de déconnexion
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                "DÉCONNEXION",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
