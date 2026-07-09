import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/mock/data/mock_patients.dart';

class NutritionScreen extends StatelessWidget {
  final String patientId;

  const NutritionScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = MockPatients.list.firstWhere((p) => p['id'] == patientId,
        orElse: () => MockPatients.list.first);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(title: Text('Nutrition - ${patient['nom']} ${patient['prenom']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _metricTile('Poids', '${70 + (patient['age'] as int) % 20}', 'kg')),
                const SizedBox(width: 8),
                Expanded(child: _metricTile('Taille', '${160 + (patient['age'] as int) % 20}', 'cm')),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Besoins nutritionnels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(height: 16),
                    _nutrientRow('Calories', '${(patient['tbsa'] as int) * 25 + 1800}', 'kcal/j', (patient['tbsa'] as int) * 25 + 1800, 3000),
                    _nutrientRow('Protéines', '${(patient['tbsa'] as int) * 2 + 80}', 'g/j', (patient['tbsa'] as int) * 2 + 80, 130),
                    _nutrientRow('Lipides', '${(patient['tbsa'] as int) + 50}', 'g/j', (patient['tbsa'] as int) + 50, 85),
                    _nutrientRow('Glucides', '${(patient['tbsa'] as int) * 3 + 200}', 'g/j', (patient['tbsa'] as int) * 3 + 200, 350),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.medication_liquid_outlined, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Voie nutritionnelle', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Nutrition entérale + orale', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.successColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Text('EN COURS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.successColor)),
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

  Widget _metricTile(String label, String value, String unit) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 3),
                  child: Text(unit, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientRow(String label, String value, String unit, int current, int target) {
    final ratio = (current / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('$value $unit', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppTheme.surfaceColor,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}