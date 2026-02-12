import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../widgets/fat_fat_logo.dart';
import '../service/api.dart';
import 'driver_gains_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_navigation_screen.dart';

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
    _refreshTimer
        ?.cancel(); // Sécurité : On arrête le timer si on quitte l'écran
    super.dispose();
  }

  // ---------------------------------------------------------
  // 1. LOGIQUE DE DISPONIBILITÉ (BACKEND SYNC)
  // ---------------------------------------------------------
  Future<void> _toggleAvailability(bool value) async {
    // Optimisme UI : On change l'état visuel immédiatement
    setState(() => _isAvailable = value);

    final res = await Api.toggleAvailability();

    if (res['status'] == 200) {
      // On synchronise avec la réponse réelle de Laravel
      bool newState =
          res['body']['disponible'] == 1 || res['body']['disponible'] == true;
      setState(() => _isAvailable = newState);

      if (newState) {
        _startAutoRefresh();
      } else {
        _stopAutoRefresh();
      }
    } else {
      // En cas d'échec, on revient à l'état précédent
      setState(() => _isAvailable = !value);
      _showSnackBar("Erreur de connexion au serveur", Colors.red);
    }
  }

  // ---------------------------------------------------------
  // 2. SYSTÈME DE POLLING (RECHERCHE DE MISSIONS)
  // ---------------------------------------------------------
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

  // ---------------------------------------------------------
  // 3. ACCEPTATION DE MISSION & NAVIGATION GPS
  // ---------------------------------------------------------
  Future<void> _acceptMission(int id) async {
    final success = await Api.acceptMission(id);

    if (success) {
      if (mounted) {
        _showSnackBar("Course acceptée ! Initialisation GPS...", Colors.green);

        // Redirection vers l'écran de navigation active
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DriverNavigationScreen(commandeId: id),
          ),
        );
      }
    } else {
      if (mounted) {
        _showSnackBar(
          "Cette course a déjà été prise par un autre livreur",
          Colors.orange,
        );
        _fetchMissions();
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FatFatLogo(size: 24),
        actions: [_buildAvailabilityToggle()],
      ),
      // IndexedStack préserve l'état de chaque onglet (Gains, Profil, Liste)
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMissionsList(),
          const DriverGainsScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Missions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Gains'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildAvailabilityToggle() {
    return Row(
      children: [
        Text(
          _isAvailable ? "EN LIGNE" : "HORS LIGNE",
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: _isAvailable,
          onChanged: _toggleAvailability,
          activeColor: Colors.green,
          activeTrackColor: Colors.green.withOpacity(0.2),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildMissionsList() {
    if (!_isAvailable) {
      return _buildEmptyState(
        Icons.cloud_off,
        "Vous êtes déconnecté",
        "Activez votre disponibilité pour voir les courses.",
      );
    }

    if (_missions.isEmpty) {
      return _buildEmptyState(
        Icons.search,
        "Recherche de missions...",
        "Patientez, les commandes de Dakar arrivent.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _missions.length,
      itemBuilder: (context, index) => _buildMissionCard(_missions[index]),
    );
  }

  Widget _buildMissionCard(dynamic mission) {
    bool isColis = mission['type_service_id'] == 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(isColis ? "COLIS" : "TRANSPORT"),
                  backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "${mission['prix_total']} FCFA",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildRouteInfo(
              Icons.circle,
              Colors.blue,
              mission['adresse_depart'],
            ),
            const SizedBox(height: 10),
            _buildRouteInfo(
              Icons.location_on,
              Colors.red,
              mission['adresse_arrivee'],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _acceptMission(mission['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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

  Widget _buildRouteInfo(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
