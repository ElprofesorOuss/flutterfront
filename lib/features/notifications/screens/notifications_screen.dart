import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'titre': 'Nouvelle photo J+10', 'description': 'Photos de greffe pour Bernard Jean disponibles', 'temps': 'Il y a 5 min', 'type': 'photo'},
      {'titre': 'Alerte critique: Bernard Jean', 'description': 'Défaillance rénale suspectée - Créatinine 250 µmol/L', 'temps': 'Il y a 12 min', 'type': 'critique'},
      {'titre': 'Pansement à revoir: Dubois Pierre', 'description': 'Pansement A-101 à renouveler dans 2h', 'temps': 'Il y a 30 min', 'type': 'pansement'},
      {'titre': 'Alerte sévère: Moreau Sophie', 'description': 'Fièvre > 39.5°C persistante', 'temps': 'Il y a 2h', 'type': 'critique'},
      {'titre': 'Rappel: Staff brûlés', 'description': 'Réunion d\'équipe à 14h - Salle de conférence', 'temps': 'Il y a 3h', 'type': 'general'},
      {'titre': 'Patient critique: Bernard Jean', 'description': 'Transfert réanimation discuté', 'temps': 'Il y a 4h', 'type': 'critique'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (ctx, i) {
          final n = notifications[i];
          IconData icon;
          Color color;
          switch (n['type']) {
            case 'critique':
              icon = Icons.warning_amber_rounded;
              color = SeverityColors.critical;
              break;
            case 'photo':
              icon = Icons.camera_alt_outlined;
              color = AppTheme.primaryColor;
              break;
            case 'pansement':
              icon = Icons.healing_outlined;
              color = SeverityColors.severe;
              break;
            default:
              icon = Icons.notifications_outlined;
              color = AppTheme.textSecondary;
          }

          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(n['titre']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(n['description']!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(n['temps']!, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          );
        },
      ),
    );
  }
}