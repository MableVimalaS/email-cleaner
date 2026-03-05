import 'package:flutter/material.dart';

import '../models/email_sender.dart';

class SenderTile extends StatelessWidget {
  final EmailSender sender;
  final VoidCallback? onTap;

  const SenderTile({super.key, required this.sender, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Text(
          sender.name.isNotEmpty ? sender.name[0].toUpperCase() : '?',
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
        ),
      ),
      title: Text(
        sender.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        sender.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sender.hasUnsubscribe)
            Icon(Icons.unsubscribe, size: 16, color: theme.colorScheme.tertiary),
          const SizedBox(width: 8),
          Chip(
            label: Text('${sender.messageCount}'),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
