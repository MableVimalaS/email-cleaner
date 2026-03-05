import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cleanup_provider.dart';

class CleanupConfirmScreen extends StatelessWidget {
  final List<int> uids;

  const CleanupConfirmScreen({super.key, required this.uids});

  @override
  Widget build(BuildContext context) {
    final cleanup = context.watch<CleanupProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Cleanup')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cleanup.state == CleanupState.idle) ...[
                Icon(Icons.delete_sweep, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Delete ${uids.length} emails?',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<CleanupProvider>().deleteMessages(uids),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
              if (cleanup.state == CleanupState.deleting) ...[
                CircularProgressIndicator(value: cleanup.progress),
                const SizedBox(height: 16),
                Text('Deleting ${cleanup.deleted} of ${cleanup.total}...'),
              ],
              if (cleanup.state == CleanupState.done) ...[
                Icon(Icons.check_circle, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Deleted ${cleanup.total} emails',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    cleanup.reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
              if (cleanup.state == CleanupState.error) ...[
                Icon(Icons.error, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(cleanup.errorMessage ?? 'Deletion failed'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    cleanup.reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
