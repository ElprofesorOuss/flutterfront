import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/app/router/app_router.dart';


class PhotoGalleryScreen extends StatelessWidget {
  final String patientId;

  const PhotoGalleryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: const Text('Galerie photos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            _photoItem(context, 'Admission', 'J0', 'critique'),
            _photoItem(context, 'J+3', '03/07', 'sévère'),
            _photoItem(context, 'J+7', '07/07', 'modérée'),
            _photoItem(context, 'J+10', '10/07', 'modérée'),
            _photoItem(context, 'Pansement', '12/07', 'faible'),
            _photoItem(context, 'Greffe J1', '14/07', 'faible'),
          ],
        ),
      ),
    );
  }

  Widget _photoItem(BuildContext context, String label, String date, String severity) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.photoDetail, arguments: {'photoId': label}),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 32, color: AppTheme.textLight),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            Text(date, style: const TextStyle(fontSize: 10, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }
}