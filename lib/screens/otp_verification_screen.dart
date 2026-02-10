import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../service/api.dart';

class OtpVerificationScreen extends StatefulWidget {
  final int commandeId;
  const OtpVerificationScreen({super.key, required this.commandeId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  // Méthode pour valider le code auprès de l'API Laravel
  Future<void> _validateOtp() async {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir les 4 chiffres du code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Envoi de la commandeId et du codeOtp au service API
    final res = await Api.confirmerLivraison(
      widget.commandeId,
      _otpController.text,
    );

    setState(() => _isLoading = false);

    if (res['success'] == true) {
      if (mounted) {
        // Retour à l'accueil après succès
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Livraison validée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Code OTP incorrect"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Validation OTP", style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primaryRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_person_rounded,
              size: 80,
              color: AppColors.primaryRed,
            ),
            const SizedBox(height: 24),
            Text(
              "Code de vérification",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Veuillez saisir le code à 4 chiffres fourni par le client pour finaliser la course.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Champ de saisie OTP
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: "",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "CONFIRMER LA RÉCEPTION",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
