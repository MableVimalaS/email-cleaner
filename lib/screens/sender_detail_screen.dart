import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/sender_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/email_tile.dart';
import 'cleanup_confirm_screen.dart';

class SenderDetailScreen extends StatelessWidget {
  final String email;

  const SenderDetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SenderProvider>();
    final sender = provider.getSender(email);
    final theme = Theme.of(context);

    if (sender == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sender')),
        body: const Center(child: Text('Sender not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(sender.name),
      ),
      body: Column(
        children: [
          // Sender info header
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sender.email, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('${sender.messageCount} emails',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _deleteAll(context, sender.uids),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete All'),
                      ),
                      if (sender.hasUnsubscribe) ...[
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          onPressed: () => _unsubscribe(sender.unsubscribeUrl),
                          icon: const Icon(Icons.unsubscribe),
                          label: const Text('Unsubscribe'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Messages list
          Expanded(
            child: ListView.builder(
              itemCount: sender.messages.length,
              itemBuilder: (context, index) {
                return EmailTile(message: sender.messages[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAll(BuildContext context, List<int> uids) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete All',
      message: 'Delete all ${uids.length} emails from this sender?',
    );
    if (confirmed == true && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CleanupConfirmScreen(uids: uids),
        ),
      );
    }
  }

  Future<void> _unsubscribe(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
