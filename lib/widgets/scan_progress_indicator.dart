import 'package:flutter/material.dart';

class ScanProgressIndicator extends StatelessWidget {
  final int fetched;
  final int total;
  final double progress;

  const ScanProgressIndicator({
    super.key,
    required this.fetched,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 6,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$fetched of $total emails',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Scanning inbox...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
