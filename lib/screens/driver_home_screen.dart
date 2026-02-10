import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../widgets/fat_fat_logo.dart';
import '../service/api.dart';
import 'driver_gains_screen.dart';
import 'driver_navigation_screen.dart'; // Import crucial pour la bascule

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _selectedIndex = 0;
  bool _isAvailable = false;
  List<dynamic> _missions = [];
  Timer? _refreshTimer;

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Toujours arrêter le timer
    super.dispose();
  }

  // --- LOGIQUE MÉTIER ---

  // 1. Basculer la disponibilité (En ligne / Hors ligne)
  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);

    final res = await Api.toggleAvailability();

    if (res['status'] == 200) {
      bool newState =
          res['body']['disponible'] == 1 || res['body']['disponible'] == true;
      setState(() => _isAvailable = newState);

      if (newState) {
        _startAutoRefresh();
      } else {
        _stopAutoRefresh();
      }
    } else {
      setState(() => _isAvailable = !value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion au serveur")),
      );
    }
  }

  // 2. Polling : Recherche automatique de missions
  void _startAutoRefresh() {
    _fetchMissions();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMissions();
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    setState(() => _missions = []);
  }

  Future<void> _fetchMissions() async {
    final missions = await Api.getAvailableMissions();
    if (mounted) {
      setState(() => _missions = missions);
    }
  }

  // 3. ACCEPTER LA MISSION ET BASCULER VERS LA NAVIGATION
  Future<void> _acceptMission(int id) async {
    final success = await Api.acceptMission(id);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Course acceptée ! Préparation de l'itinéraire..."),
            backgroundColor: Colors.green,
          ),
        );

        // --- BASCULE VERS LA PAGE DE NAVIGATION ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverNavigationScreen(commandeId: id),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Désolé, cette course n'est plus disponible"),
            backgroundColor: Colors.red,
          ),
        );
        _fetchMissions(); // Rafraîchir la liste
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FatFatLogo(size: 24),
        actions: [
          Row(
            children: [
              Text(
                _isAvailable ? "En ligne" : "Hors ligne",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: _toggleAvailability,
                activeColor: AppColors.primaryYellow,
                activeTrackColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildMissionsList()
          : _selectedIndex == 1
          ? const DriverGainsScreen()
          : const Center(child: Text("Paramètres du Profil")),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryRed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Gains',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMissionsList() {
    if (!_isAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "Vous êtes hors ligne",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
            ),
            Text(
              "Mettez-vous en ligne pour voir les livraisons",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryRed),
            const SizedBox(height: 20),
            Text(
              "Recherche de courses à Dakar...",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _missions.length,
      itemBuilder: (context, index) => _buildMissionCard(_missions[index]),
    );
  }

  Widget _buildMissionCard(dynamic mission) {
    String type = mission['type_service_id'] == 1 ? "Colis" : "Transport";
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      type == "Colis" ? Icons.inventory : Icons.person,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${mission['prix_total']} FCFA",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildLocationRow(
              Icons.my_location,
              Colors.blue,
              mission['adresse_depart'] ?? "Départ",
            ),
            const SizedBox(height: 10),
            _buildLocationRow(
              Icons.flag,
              AppColors.primaryRed,
              mission['adresse_arrivee'] ?? "Destination",
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _acceptMission(mission['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "ACCEPTER LA COURSE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
