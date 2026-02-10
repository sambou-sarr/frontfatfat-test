import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';
import '../service/api.dart';

class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({super.key});

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  int? id;

  @override
  void initState() {
    super.initState();
    _initAppData();
  }

  // --- 1. RÉCUPÉRATION DES INFOS UTILISATEUR ---
  Future<void> _initAppData() async {
    try {
      final userRes = await Api.getUserInfo();

      if (userRes['status'] == 200) {
        // Attention : vérifiez si votre API renvoie 'id' ou 'id_client'
        var data = userRes['body']['body'];
        int extractedId = data['id'] ?? data['id_client'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', extractedId.toString());

        if (mounted) {
          setState(() {
            id = extractedId;
          });
          _fetchHistory();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Erreur initialisation : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. RÉCUPÉRATION DE L'HISTORIQUE ---
  Future<void> _fetchHistory() async {
    if (id == null) return;

    setState(() => _isLoading = true);
    try {
      final res = await Api.getUserMissions(id!);

      if (res['status'] == 200) {
        if (mounted) {
          setState(() {
            _history = res['body']['body'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        _showError("Erreur lors de la récupération");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showError("Erreur de connexion au serveur");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- LOGIQUE VISUELLE ---
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case "livrée":
      case "termine":
        return Colors.green;
      case "annulée":
        return Colors.redAccent;
      case "en_cours":
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Mes Missions"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryRed),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : _history.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              color: AppColors.primaryRed,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _history.length,
                itemBuilder: (context, index) =>
                    _buildMissionCard(_history[index]),
              ),
            ),
    );
  }

  Widget _buildMissionCard(dynamic mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    mission['type_service_id'] == 1
                        ? Icons.inventory
                        : Icons.person,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mission['type_service_id'] == 1 ? "Colis" : "Transport",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(mission['statut']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (mission['statut'] ?? "Attente").toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildRouteRow(
            mission['adresse_depart'] ?? "Position actuelle",
            mission['adresse_arrivee'] ?? "Destination",
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${mission['prix_total'] ?? 0} FCFA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryRed,
                ),
              ),
              Text(
                mission['created_at']?.split('T')[0] ?? "",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(String from, String to) {
    return Row(
      children: [
        Column(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.blue),
            Container(width: 1, height: 20, color: Colors.grey[300]),
            const Icon(
              Icons.location_on,
              size: 14,
              color: AppColors.primaryRed,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                from,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                to,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucune mission",
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
