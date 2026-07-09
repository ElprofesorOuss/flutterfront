import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/shared/widgets/patient_card.dart';
import 'package:burning2026/shared/widgets/alert_card.dart';
import 'package:burning2026/shared/widgets/metric_tile.dart';
import 'package:burning2026/shared/widgets/quick_action_button.dart';
import 'package:burning2026/shared/widgets/section_header.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = MockPatients.list;
    final criticalCount = patients.where((p) => p['severite'] == 'critique').length;
    final activeCount = patients.length;
    final todayCount = patients.where((p) => p['date_admission'] == '2026-07-05').length;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Centre des Brûlés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Bonjour Dr. Martin',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      label: 'Hospitalisés',
                      value: '$activeCount',
                      icon: Icons.bed_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricTile(
                      label: 'Critiques',
                      value: '$criticalCount',
                      icon: Icons.warning_amber_rounded,
                      valueColor: AppTheme.criticalColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MetricTile(
                      label: 'Aujourd\'hui',
                      value: '$todayCount',
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Accès rapide'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    QuickActionButton(
                      icon: Icons.people_outline,
                      label: 'Patients',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.patientList),
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'Alertes',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.alerts),
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      icon: Icons.timeline_outlined,
                      label: 'Trajectoire',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.trajectory, arguments: {'patientId': 'P001'}),
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      icon: Icons.restaurant_outlined,
                      label: 'Nutrition',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.nutrition, arguments: {'patientId': 'P001'}),
                    ),
                    const SizedBox(width: 8),
                    QuickActionButton(
                      icon: Icons.description_outlined,
                      label: 'Observations',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.observations, arguments: {'patientId': 'P001'}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Alertes critiques',
              trailing: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.alerts),
                child: const Text('Voir tout'),
              ),
            ),
            AlertCard(
              title: 'Défaillance rénale suspectée',
              description: 'Patient Bernard Jean - B-201 - TBSA 45%',
              severity: 'critique',
              time: 'Il y a 12 min',
            ),
            AlertCard(
              title: 'Hypotension sévère',
              description: 'Patient Dubois Pierre - A-101 - TBSA 32%',
              severity: 'critique',
              time: 'Il y a 35 min',
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Patients à revoir',
              trailing: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.patientList),
                child: const Text('Voir tout'),
              ),
            ),
            ...patients.where((p) => p['severite'] == 'sévère' || p['severite'] == 'critique').map((p) => PatientCard(
              nom: p['nom']!,
              prenom: p['prenom']!,
              age: p['age'] as int,
              ipp: p['ipp']!,
              lit: p['lit']!,
              tbsa: p['tbsa'] as int,
              severite: p['severite']!,
              statut: p['statut']!,
              onTap: () => Navigator.pushNamed(context, AppRoutes.patientDetail, arguments: {'patientId': p['id']}),
            )),
          ],
        ),
      ),
    );
  }
}