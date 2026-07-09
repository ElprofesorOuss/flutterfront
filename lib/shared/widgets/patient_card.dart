import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/shared/widgets/severity_badge.dart';

class PatientCard extends StatelessWidget {
  final String nom;
  final String prenom;
  final int age;
  final String ipp;
  final String lit;
  final int tbsa;
  final String severite;
  final String statut;
  final VoidCallback? onTap;

  const PatientCard({
    super.key,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.ipp,
    required this.lit,
    required this.tbsa,
    required this.severite,
    required this.statut,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  '${nom[0]}${prenom[0]}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nom $prenom, $age ans',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _infoChip(context, Icons.badge_outlined, ipp),
                        const SizedBox(width: 8),
                        _infoChip(context, Icons.bed_outlined, lit),
                        const SizedBox(width: 8),
                        _infoChip(
                            context, Icons.local_fire_department, 'TBSA $tbsa%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SeverityBadge(level: severite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}