import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/email_category.dart';
import '../providers/category_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/email_tile.dart';
import 'cleanup_confirm_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final EmailCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final messages = provider.messagesFor(category);
    final selectedCount = provider.selectedUids
        .where((uid) => messages.any((m) => m.uid == uid))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.label),
        actions: [
          if (selectedCount > 0)
            TextButton.icon(
              onPressed: () => _deleteSelected(context, provider),
              icon: const Icon(Icons.delete),
              label: Text('Delete ($selectedCount)'),
            ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'select_all') provider.selectAll(category);
              if (v == 'deselect') provider.deselectAll();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'select_all',
                child: Text('Select All'),
              ),
              const PopupMenuItem(
                value: 'deselect',
                child: Text('Deselect All'),
              ),
            ],
          ),
        ],
      ),
      body: messages.isEmpty
          ? const Center(child: Text('No emails in this category'))
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return EmailTile(
                  message: msg,
                  selectable: true,
                  selected: provider.isSelected(msg.uid),
                  onSelected: (_) => provider.toggleSelection(msg.uid),
                );
              },
            ),
    );
  }

  Future<void> _deleteSelected(
      BuildContext context, CategoryProvider provider) async {
    final uids = provider.selectedUids.toList();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Emails',
      message: 'Delete ${uids.length} selected emails?',
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
}
