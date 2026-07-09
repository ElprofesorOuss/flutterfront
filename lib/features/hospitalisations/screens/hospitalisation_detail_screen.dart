import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';

import 'package:burning2026/shared/widgets/severity_badge.dart';
import 'package:burning2026/shared/widgets/timeline_item.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class HospitalisationDetailScreen extends StatelessWidget {
  final String hospitalisationId;

  const HospitalisationDetailScreen({super.key, required this.hospitalisationId});

  @override
  Widget build(BuildContext context) {
    final patient = MockPatients.list.firstWhere((p) => p['id'] == hospitalisationId,
        orElse: () => MockPatients.list.first);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: const Text('Hospitalisation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${patient['nom']} ${patient['prenom']}',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        SeverityBadge(level: patient['severite']!),
                      ],
                    ),
                    const Divider(height: 20),
                    _row('IPP', patient['ipp']!),
                    _row('Lit', patient['lit']!),
                    _row('Date admission', patient['date_admission']!),
                    _row('Mécanisme', patient['mecanisme']!),
                    _row('TBSA', '${patient['tbsa']}%'),
                    _row('Profondeur', patient['profondeur']!),
                    _row('Inhalation', patient['inhalation'] ? 'Oui' : 'Non'),
                    _row('Statut clinique', patient['statut']!),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TimelineItem(title: 'Admission', date: patient['date_admission'], icon: Icons.local_hospital, isFirst: true, isActive: true),
                  TimelineItem(title: 'Réanimation', date: 'J0', icon: Icons.bloodtype_outlined, isActive: true),
                  TimelineItem(title: 'Pansement initial', date: 'J+1', icon: Icons.healing_outlined, isActive: true),
                  TimelineItem(title: 'Bloc opératoire', date: 'J+5', icon: Icons.biotech_outlined),
                  TimelineItem(title: 'Greffe', date: 'Prévue J+14', icon: Icons.science_outlined),
                  TimelineItem(title: 'Rééducation', date: 'À planifier', icon: Icons.accessibility_new_outlined),
                  TimelineItem(title: 'Sortie', date: 'Prévue J+30', icon: Icons.home_outlined, isLast: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}