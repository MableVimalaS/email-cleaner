import 'package:flutter/material.dart';

import '../models/email_category.dart';

class CategoryCard extends StatelessWidget {
  final CategorySummary summary;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = summary.category;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cat.icon, color: cat.color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.label,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${summary.count}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cat.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatSize(summary.totalSize),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
