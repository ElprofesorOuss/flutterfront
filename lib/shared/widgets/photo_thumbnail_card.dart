import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_theme.dart';
import 'package:burning2026/core/theme/app_colors.dart';

class PhotoThumbnailCard extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback? onTap;
  final Color? borderColor;

  const PhotoThumbnailCard({
    super.key,
    required this.label,
    required this.date,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 28,
              color: AppTheme.primaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            Text(
              date,
              style: TextStyle(fontSize: 8, color: colors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}