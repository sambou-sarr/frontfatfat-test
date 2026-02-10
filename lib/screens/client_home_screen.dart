import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Imports de votre projet FAT FAT
import '../themes/app_theme.dart';
import '../widgets/mission_type_card.dart';
import '../service/api.dart';
import 'client_history_screen.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _selectedIndex = 0;
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  String userName = "Chargement...";
  bool _isLoading = true;
  bool _isSearching = false;
  int? _prixFinal;
  int? id;

  @override
  void initState() {
    super.initState();
    _initAppData();
  }

  // --- INITIALISATION : GPS & INFOS UTILISATEUR ---
  Future<void> _initAppData() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final userRes = await Api.getUserInfo();

      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        if (userRes['status'] == 200) {
          var data = userRes['body']['body'];
          userName = "${data['prenom']} ${data['nom']}";
          id = data['id'];
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur initialisation : $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIQUE DE RECHERCHE & ESTIMATION ---
  Future<void> _handleSearch(
    String address,
    int serviceId,
    StateSetter setModalState,
  ) async {
    if (address.isEmpty) return;
    setModalState(() => _isSearching = true);

    final coords = await Api.getCoordinatesFromAddress(address);

    if (coords != null) {
      setState(
        () => _destinationLatLng = LatLng(coords['lat']!, coords['lng']!),
      );

      final res = await Api.estimerPrix({
        "type_service_id": serviceId,
        "distance_km": 7, // Valeur test
        "duree_min": 30, // Valeur test
      });

      if (res['status'] == 200 && res['body'] != null) {
        setModalState(() {
          _prixFinal = res['body']['body']['estimation']['prix'];
          _isSearching = false;
        });
      } else {
        setModalState(() => _isSearching = false);
        _showError("Erreur d'estimation");
      }
    } else {
      setModalState(() => _isSearching = false);
      _showError("Lieu introuvable");
    }
  }

  // --- CRÉATION DE LA COURSE ---
  Future<void> _confirmOrder(
    int serviceId,
    String destinationAddress,
    String phoneDestinataire,
  ) async {
    setState(() => _isLoading = true);

    final missionData = {
      "type_service_id": serviceId,
      "adresse_depart": "Ma position actuelle",
      "adresse_arrivee": destinationAddress,
      "telephone_destinataire": phoneDestinataire, // Nouvelle donnée ajoutée
      "lat_depart": _currentLatLng?.latitude,
      "lng_depart": _currentLatLng?.longitude,
      "lat_arrivee": _destinationLatLng?.latitude,
      "lng_arrivee": _destinationLatLng?.longitude,
      "prix_total": _prixFinal,
    };

    final res = await Api.createMission(missionData);

    if (res['status'] == 201 || res['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course créée ! En attente d'un chauffeur."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _selectedIndex = 1; // Redirection vers l'historique
        _isLoading = false;
        _prixFinal = null;
        _destinationLatLng = null;
      });
    } else {
      setState(() => _isLoading = false);
      _showError("Échec de la création");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    final List<Widget> _pages = [
      _buildMapDashboard(),
      const ClientHistoryScreen(),
      const Center(child: Text("Profil Utilisateur")),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryRed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMapDashboard() {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _currentLatLng ?? const LatLng(14.6928, -17.4467),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: [
                if (_currentLatLng != null)
                  Marker(
                    point: _currentLatLng!,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                if (_destinationLatLng != null)
                  Marker(
                    point: _destinationLatLng!,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildServiceSelection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryRed,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Text(
            "Bonjour $userName 👋",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
            child: MissionTypeCard(
              icon: FontAwesomeIcons.boxOpen,
              title: "Colis",
              color: AppColors.primaryRed,
              onTap: () => _openOrderModal(1),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MissionTypeCard(
              icon: Icons.person,
              title: "Transport",
              color: Colors.blue,
              onTap: () => _openOrderModal(2),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderModal(int serviceId) {
    final TextEditingController _addressController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    _prixFinal = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Détails du ${serviceId == 1 ? 'Colis' : 'Transport'}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),

              // CHAMP ADRESSE
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Lieu d'arrivée",
                  prefixIcon: const Icon(
                    Icons.flag,
                    color: AppColors.primaryRed,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSearch(
                      _addressController.text,
                      serviceId,
                      setModalState,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // CHAMP TÉLÉPHONE DESTINATAIRE
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Numéro du destinataire",
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: AppColors.primaryRed,
                  ),
                  hintText: "77 000 00 00",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),

              if (_prixFinal != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Tarif : $_prixFinal FCFA",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _prixFinal == null
                    ? null
                    : () {
                        if (_phoneController.text.trim().isEmpty) {
                          _showError("Le numéro du destinataire est requis");
                          return;
                        }
                        Navigator.pop(context); // Fermer le modal
                        _confirmOrder(
                          serviceId,
                          _addressController.text,
                          _phoneController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirmer la course",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
