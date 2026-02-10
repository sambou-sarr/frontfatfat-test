import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';

class FatFatLogo extends StatelessWidget {
  final double size;
  final bool lightMode;
  const FatFatLogo({super.key, this.size = 40, this.lightMode = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(FontAwesomeIcons.motorcycle,
            color: lightMode ? Colors.white : AppColors.primaryRed, size: size),
        const SizedBox(width: 10),
        Text(
          'FAT FAT',
          style: GoogleFonts.poppins(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: lightMode ? Colors.white : AppColors.darkGrey,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
