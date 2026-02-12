import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import pour la sélection d'image
import '../themes/app_theme.dart';
import '../service/api.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String driverName = "Chargement...";
  String phone = "...";
  bool isVerified = false;
  bool _isLoading = true;

  // États pour savoir si un document est en cours d'envoi
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  // Fonction pour sélectionner et envoyer un document
  Future<void> _pickAndUploadDocument(String docType) async {
    final ImagePicker picker = ImagePicker();

    // 1. Sélection de l'image (Galerie ou Caméra)
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      builder: (context) => _buildPickerOptions(context, picker),
    );

    if (image != null) {
      setState(() => _isUploading = true);

      // Simulation d'envoi à l'API (à remplacer par ton service API)
      debugPrint("Envoi du document $docType : ${image.path}");
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isUploading = false);
      _showSnackBar(
        "Document $docType envoyé avec succès !",
        color: Colors.green,
      );
    }
  }

  // BottomSheet pour choisir entre Caméra et Galerie
  Widget _buildPickerOptions(BuildContext context, ImagePicker picker) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galerie'),
            onTap: () async => Navigator.pop(
              context,
              await picker.pickImage(source: ImageSource.gallery),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Appareil Photo'),
            onTap: () async => Navigator.pop(
              context,
              await picker.pickImage(source: ImageSource.camera),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDriverData() async {
    try {
      final res =
          await Api.getUserInfol(); // Correction du nom de la fonction si nécessaire
      if (res != null && (res['status'] == 200 || res['status'] == 2)) {
        final dynamic userData = res['body']?['body'];
        if (userData != null) {
          setState(() {
            driverName = "${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}"
                .trim();
            phone = userData['telephone']?.toString() ?? "Non renseigné";
            var activeStatus = userData['is_active'];
            isVerified =
                (activeStatus == 1 ||
                activeStatus == "1" ||
                activeStatus == true);
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : Stack(
              // Utilisation d'un Stack pour afficher un loader global pendant l'upload
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 20),
                            _buildSectionTitle("Mes Documents Officiels"),

                            // TUILLE INTERACTIVES
                            _buildDocumentTile(
                              "Permis de conduire",
                              true,
                              () => _pickAndUploadDocument("Permis"),
                            ),
                            _buildDocumentTile(
                              "Carte grise moto",
                              true,
                              () => _pickAndUploadDocument("Carte Grise"),
                            ),
                            _buildDocumentTile(
                              "Assurance",
                              false,
                              () => _pickAndUploadDocument("Assurance"),
                            ),

                            const SizedBox(height: 20),
                            _buildSectionTitle("Compte"),
                            _buildMenuTile(
                              Icons.history,
                              "Historique de mes courses",
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/delivery_history',
                              ),
                            ),
                            _buildMenuTile(
                              Icons.settings,
                              "Paramètres du compte",
                              onTap: () {},
                            ),
                            const SizedBox(height: 30),
                            _buildLogoutButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUploading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryYellow,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryYellow,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 15),
            Text(
              driverName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              phone,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(
          isVerified ? Icons.verified : Icons.warning_amber_rounded,
          color: isVerified ? Colors.green : Colors.orange,
          size: 30,
        ),
        title: Text(
          isVerified ? "Compte Vérifié" : "Vérification en cours",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isVerified
              ? "Vous pouvez recevoir des missions"
              : "Veuillez compléter vos documents",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDocumentTile(String title, bool isOk, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap, // Clic pour charger
        leading: Icon(
          isOk ? Icons.check_circle : Icons.cloud_upload,
          color: isOk ? Colors.green : Colors.blue,
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
        subtitle: Text(
          isOk ? "Document validé" : "Appuyez pour charger",
          style: const TextStyle(fontSize: 11),
        ),
        trailing: const Icon(Icons.add_a_photo, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "DÉCONNEXION",
          style: GoogleFonts.poppins(
            color: AppColors.primaryRed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
