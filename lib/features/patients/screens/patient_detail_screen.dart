import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/app/router/app_router.dart';
import 'package:burning2026/shared/widgets/severity_badge.dart';
import 'package:burning2026/shared/widgets/alert_card.dart';
import 'package:burning2026/shared/widgets/photo_thumbnail_card.dart';
import 'package:burning2026/shared/widgets/section_header.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = MockPatients.list.firstWhere((p) => p['id'] == patientId,
        orElse: () => MockPatients.list.first);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text('${patient['nom']} ${patient['prenom']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.alerts),
          ),
        ],
      ),
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
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            '${patient['nom'][0]}${patient['prenom'][0]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${patient['nom']} ${patient['prenom']}, ${patient['age']} ans',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('IPP: ${patient['ipp']}',
                                      style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(width: 12),
                                  Text('Lit: ${patient['lit']}',
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SeverityBadge(level: patient['severite']!),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem('TBSA', '${patient['tbsa']}%'),
                        _infoItem('Mécanisme', patient['mecanisme']!),
                        _infoItem('Profondeur', patient['profondeur']!),
                        _infoItem('Inhalation', patient['inhalation'] ? 'Oui' : 'Non'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SectionHeader(
              title: 'Modules patient',
              trailing: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.hospitalisationDetail,
                    arguments: {'hospitalisationId': patient['id']}),
                child: const Text('Hospitalisation'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _moduleButton(context, 'Photos', Icons.camera_alt_outlined, AppRoutes.photoGallery, patient['id']),
                  const SizedBox(width: 8),
                  _moduleButton(context, 'Trajectoire', Icons.timeline_outlined, AppRoutes.trajectory, patient['id']),
                  const SizedBox(width: 8),
                  _moduleButton(context, 'Nutrition', Icons.restaurant_outlined, AppRoutes.nutrition, patient['id']),
                  const SizedBox(width: 8),
                  _moduleButton(context, 'Observations', Icons.description_outlined, AppRoutes.observations, patient['id']),
                ],
              ),
            ),
            const SectionHeader(title: 'Alertes actives'),
            AlertCard(
              title: 'Score ABSI élevé',
              description: 'Patient ${patient['nom']} - Score: ${patient['tbsa']}',
              severity: patient['severite']!,
              time: 'Dernière alerte: aujourd\'hui',
            ),
            const SizedBox(height: 8),
            const SectionHeader(title: 'Photos récentes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    PhotoThumbnailCard(
                      label: 'Admission',
                      date: 'J0',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '1'}),
                    ),
                    const SizedBox(width: 8),
                    PhotoThumbnailCard(
                      label: 'J+3',
                      date: '03/07',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '3'}),
                      borderColor: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    PhotoThumbnailCard(
                      label: 'J+7',
                      date: '07/07',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '7'}),
                    ),
                    const SizedBox(width: 8),
                    PhotoThumbnailCard(
                      label: 'J+10',
                      date: '10/07',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': '10'}),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _moduleButton(BuildContext context, String label, IconData icon, String route, String pid) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pushNamed(context, route, arguments: {'patientId': pid}),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}