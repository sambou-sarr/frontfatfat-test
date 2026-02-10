import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import 'otp_verification_screen.dart';

class DriverNavigationScreen extends StatefulWidget {
  final int commandeId;
  const DriverNavigationScreen({super.key, required this.commandeId});

  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  bool _isStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Course #${widget.commandeId}",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.primaryRed,
      ),
      body: Stack(
        children: [
          // 1. CARTE INTERACTIVE (Utilise OpenStreetMap) [cite: 526, 608, 610]
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(
                14.7167,
                -17.4677,
              ), // Centré sur Dakar [cite: 334, 372]
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              // CORRECTION ICI : Utilisation de 'child' au lieu de 'builder'
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(14.7167, -17.4677),
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.motorcycle,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. PANNEAU DE CONTRÔLE [cite: 707, 725, 726]
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isStarted
                        ? "EN ROUTE VERS LA DESTINATION"
                        : "DIRECTION : POINT DE RAMASSAGE",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _isStarted ? Colors.green : AppColors.primaryRed,
                    ),
                  ),
                  const Divider(height: 30),

                  const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Client : Fatou Sarr"),
                    subtitle: Text(
                      "Dakar Plateau -> Almadies",
                    ), // Zones couvertes [cite: 335]
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isStarted) {
                          setState(() => _isStarted = true);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen(
                                commandeId: widget.commandeId,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isStarted
                            ? AppColors.primaryRed
                            : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _isStarted
                            ? "CONFIRMER L'ARRIVÉE"
                            : "DÉMARRER LA COURSE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
