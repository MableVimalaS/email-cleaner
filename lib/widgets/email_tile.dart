import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/email_message.dart';

class EmailTile extends StatelessWidget {
  final EmailMessage message;
  final bool selected;
  final bool selectable;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onSelected;

  const EmailTile({
    super.key,
    required this.message,
    this.selected = false,
    this.selectable = false,
    this.onTap,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _formatDate(message.date);

    return ListTile(
      leading: selectable
          ? Checkbox(value: selected, onChanged: onSelected)
          : CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
      title: Text(
        message.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        message.senderName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        dateStr,
        style: theme.textTheme.bodySmall,
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().format(date);
    if (date.year == now.year) return DateFormat.MMMd().format(date);
    return DateFormat.yMMMd().format(date);
  }
}
