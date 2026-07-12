import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_colors.dart';

class FilterSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int? resultCount;

  const FilterSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Rechercher...',
    required this.onChanged,
    this.onFilterTap,
    this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: colors.textLight),
                prefixIcon: Icon(Icons.search, color: colors.textLight),
                filled: true,
                fillColor: colors.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                color: colors.textSecondary,
                onPressed: onFilterTap,
              ),
            ),
          ],
          if (resultCount != null) ...[
            const SizedBox(width: 8),
            Text(
              '$resultCount résultats',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}