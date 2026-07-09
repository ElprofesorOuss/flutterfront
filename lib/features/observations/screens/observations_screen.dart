import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class ObservationsScreen extends StatelessWidget {
  final String patientId;

  const ObservationsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = MockPatients.list.firstWhere((p) => p['id'] == patientId,
        orElse: () => MockPatients.list.first);

    final observations = [
      {'auteur': 'Dr. Martin', 'heure': '08:30', 'categorie': 'Clinique', 'criticite': 'critique', 'note': 'Patient hypotendu (PAS 65 mmHg). Expansion volémique en cours. Surveillance rapprochée.'},
      {'auteur': 'Dr. Martin', 'heure': '08:30', 'categorie': 'Inhalation', 'criticite': 'critique', 'note': 'Toux, encombrement bronchique. Kiné respiratoire 2x/j. Spirométrie incitative.'},
      {'auteur': 'Inf. Dubois', 'heure': '06:00', 'categorie': 'Pansement', 'criticite': 'sévère', 'note': 'Pansement humide sur membre supérieur droit. Aspect propre, exsudat modéré.'},
      {'auteur': 'Inf. Dubois', 'heure': '04:00', 'categorie': 'Paramètres', 'criticite': 'modérée', 'note': 'Diurèse conservée 0.8 mL/kg/h. Température 38.2°C.'},
      {'auteur': 'Dr. Petit', 'heure': '22:00', 'categorie': 'Nutrition', 'criticite': 'modérée', 'note': 'SNG bien tolérée. Apport calorique 60% des besoins. Complément oral proposé.'},
      {'auteur': 'Inf. Dubois', 'heure': '20:00', 'categorie': 'Général', 'criticite': 'faible', 'note': 'Patient algique. EVA 4/10. Paracétamol administré.'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: Text('Observations - ${patient['nom']} ${patient['prenom']}')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: observations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final obs = observations[i];
          final color = SeverityColors.fromLevel(obs['criticite']!);
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 3, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(obs['categorie']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text(obs['criticite']!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(obs['auteur']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                const SizedBox(width: 8),
                                Text(obs['date']!, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(obs['note']!, style: const TextStyle(fontSize: 13, height: 1.3)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}