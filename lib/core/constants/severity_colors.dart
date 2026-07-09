import 'package:flutter/material.dart';

class SeverityColors {
  SeverityColors._();

  static const Color low = Color(0xFF4CAF50);
  static const Color moderate = Color(0xFFFFA726);
  static const Color severe = Color(0xFFEF5350);
  static const Color critical = Color(0xFFB71C1C);

  static Color fromLevel(String level) {
    switch (level.toLowerCase()) {
      case 'faible':
      case 'low':
        return low;
      case 'modérée':
      case 'moderate':
        return moderate;
      case 'sévère':
      case 'severe':
        return severe;
      case 'critique':
      case 'critical':
        return critical;
      default:
        return moderate;
    }
  }
}