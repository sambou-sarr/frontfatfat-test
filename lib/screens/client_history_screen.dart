import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';

class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({super.key});

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  // --- DONNÉES FICTIVES (MOCK DATA) ---
  final List<Map<String, dynamic>> _mockHistory = [
    {
      "id": 16,
      "adresse_depart": "Ma position actuelle (Plateau)",
      "adresse_arrivee": "Yoff, Cité Biagui",
      "prix_total": 2000,
      "statut": "ACCEPTEE",
      "created_at": "2026-02-12T14:08:04.000000Z",
    },
    {
      "id": 15,
      "adresse_depart": "Place de l'Indépendance",
      "adresse_arrivee": "Monument de la Renaissance",
      "prix_total": 2500,
      "statut": "EN_ATTENTE",
      "created_at": "2026-02-10T17:28:26.000000Z",
    },
    {
      "id": 1,
      "adresse_depart": "Dakar Plateau",
      "adresse_arrivee": "Mermoz École de Police",
      "prix_total": 1550,
      "statut": "LIVREE",
      "created_at": "2026-01-28T18:42:51.000000Z",
    },
    {
      "id": 5,
      "adresse_depart": "Mermoz",
      "adresse_arrivee": "Dakar Ville",
      "prix_total": 2000,
      "statut": "ANNULEE",
      "created_at": "2026-02-04T14:40:48.000000Z",
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  // Simule un appel API
  void _simulateLoading() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _history = _mockHistory;
          _isLoading = false;
        });
      }
    });
  }

  // --- LOGIQUE VISUELLE DES STATUTS ---
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toUpperCase()) {
      case "LIVREE":
      case "TERMINE":
        return Colors.green;
      case "ACCEPTEE":
        return Colors.blue;
      case "ANNULEE":
        return Colors.red;
      case "EN_ATTENTE":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Mon Historique ",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                _simulateLoading();
              },
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
              Text(
                "Course #${mission['id']}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              _buildStatusBadge(mission['statut']),
            ],
          ),
          const Divider(height: 24),
          _buildLocationRow(
            Icons.circle,
            Colors.blue,
            mission['adresse_depart'],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: SizedBox(height: 10, child: VerticalDivider(width: 1)),
          ),
          _buildLocationRow(
            Icons.location_on,
            AppColors.primaryRed,
            mission['adresse_arrivee'],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${mission['prix_total']} FCFA",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              Text(
                _formatDate(mission['created_at']),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (status ?? "Inconnu").replaceAll('_', ' '),
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String? address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            address ?? "Adresse inconnue",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateStr.split('T')[0];
    }
  }
}
