import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/timeline_item.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class TrajectoryScreen extends StatelessWidget {
  final String patientId;

  const TrajectoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = MockPatients.list.firstWhere((p) => p['id'] == patientId,
        orElse: () => MockPatients.list.first);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: Text('Trajectoire - ${patient['nom']} ${patient['prenom']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('TBSA ${patient['tbsa']}% | ${patient['mecanisme']} | ${patient['profondeur']}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TimelineItem(title: 'Admission', date: patient['date_admission'], icon: Icons.local_hospital, isFirst: true, isActive: true),
                    TimelineItem(title: 'Réanimation volémique', subtitle: 'Protocole Parkland - Lactate Ringer', date: 'J0 - J2', icon: Icons.bloodtype_outlined, isActive: true),
                    TimelineItem(title: 'Pansement initial', subtitle: 'Nettoyage + Flammacérium', date: 'J+1', icon: Icons.healing_outlined, isActive: true),
                    TimelineItem(title: 'Bloc opératoire', subtitle: 'Excision + greffe', date: 'J+5', icon: Icons.biotech_outlined),
                    TimelineItem(title: 'Greffe cutanée', subtitle: 'Autogreffe expansée', date: 'Prévu J+14', icon: Icons.science_outlined),
                    TimelineItem(title: 'Rééducation', subtitle: 'Kiné + compression', date: 'J+21', icon: Icons.accessibility_new_outlined),
                    TimelineItem(title: 'Sortie', subtitle: 'Suivi ambulatoire', date: 'Prévue J+30', icon: Icons.home_outlined, isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}