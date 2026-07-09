import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/severity_colors.dart';
import 'package:burning2026/shared/widgets/severity_badge.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String severity;
  final String time;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.description,
    required this.severity,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = SeverityColors.fromLevel(severity);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(time,
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              SeverityBadge(level: severity, fontSize: 10),
            ],
          ),
        ),
      ),
    );
  }
}