import 'package:flutter/material.dart';
import 'package:burning2026/core/constants/severity_colors.dart';

class SeverityBadge extends StatelessWidget {
  final String level;
  final double fontSize;

  const SeverityBadge({
    super.key,
    required this.level,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = SeverityColors.fromLevel(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}