import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: const Text('Alertes cliniques')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Critiques', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.criticalColor)),
          ),
          AlertCard(title: 'Défaillance rénale suspectée', description: 'Bernard Jean - B-201 - Créatinine > 200 µmol/L', severity: 'critique', time: 'Il y a 12 min'),
          AlertCard(title: 'Hypotension sévère', description: 'Dubois Pierre - A-101 - PAS < 70 mmHg', severity: 'critique', time: 'Il y a 35 min'),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Sévères', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SeverityColors.severe)),
          ),
          AlertCard(title: 'Hyperthermie', description: 'Moreau Sophie - A-102 - Température > 39.5°C', severity: 'sévère', time: 'Il y a 2h'),
          AlertCard(title: 'Douleur non contrôlée', description: 'Petit Léa - A-104 - EVA > 7/10', severity: 'sévère', time: 'Il y a 3h'),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Modérées', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SeverityColors.moderate)),
          ),
          AlertCard(title: 'Apport nutritionnel insuffisant', description: 'Leroy Marc - A-103 - 40% des besoins', severity: 'modérée', time: 'Il y a 4h'),
        ],
      ),
    );
  }
}