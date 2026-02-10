import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_theme.dart';

class DriverGainsScreen extends StatelessWidget {
  const DriverGainsScreen({super.key});

  // Données en dur pour la démonstration
  final int soldeCommission = 5250;

  final List<Map<String, dynamic>> gains = const [
    {"period": "Aujourd’hui", "missions": 3, "amount": 7500},
    {"period": "Hier", "missions": 5, "amount": 12500},
    {"period": "Cette semaine", "missions": 18, "amount": 42000},
  ];

  @override
  Widget build(BuildContext context) {
    final total = gains.fold<int>(
      0,
      (sum, item) => sum + item["amount"] as int,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CARTE DES GAINS ET COMMISSION
          _FinancialSummaryCard(total: total, commission: soldeCommission),

          const SizedBox(height: 24),

          Text(
            "Détails des gains",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: gains.length,
              itemBuilder: (context, index) {
                final gain = gains[index];
                return _GainItem(
                  period: gain["period"],
                  missions: gain["missions"],
                  amount: gain["amount"],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* =======================================================
    WIDGETS MIS À JOUR
======================================================= */

class _FinancialSummaryCard extends StatelessWidget {
  final int total;
  final int commission;

  const _FinancialSummaryCard({required this.total, required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Section Gains Totaux
              _StatColumn(
                label: "Gains Totaux",
                value: total,
                color: Colors.white,
              ),

              // Séparateur vertical
              Container(height: 40, width: 1, color: Colors.white24),

              // Section Solde Commission (Attribut du diagramme de classe)
              _StatColumn(
                label: "Commission",
                value: commission,
                color: AppColors.primaryYellow,
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Text(
            "Net à percevoir : ${total - commission} FCFA",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          "$value F",
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GainItem extends StatelessWidget {
  final String period;
  final int missions;
  final int amount;

  const _GainItem({
    required this.period,
    required this.missions,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryYellow,
          child: Icon(Icons.attach_money, color: AppColors.primaryRed),
        ),
        title: Text(
          period,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "$missions missions effectuées",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Text(
          "$amount FCFA",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryRed,
          ),
        ),
      ),
    );
  }
}
