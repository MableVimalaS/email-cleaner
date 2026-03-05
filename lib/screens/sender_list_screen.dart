import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sender_provider.dart';
import '../widgets/sender_tile.dart';
import 'sender_detail_screen.dart';

class SenderListScreen extends StatelessWidget {
  const SenderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SenderProvider>();
    final senders = provider.senders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search senders...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: provider.setSearchQuery,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<SenderSort>(
                value: provider.sort,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: SenderSort.byCount,
                    child: Text('By Count'),
                  ),
                  DropdownMenuItem(
                    value: SenderSort.byName,
                    child: Text('By Name'),
                  ),
                  DropdownMenuItem(
                    value: SenderSort.bySize,
                    child: Text('By Size'),
                  ),
                  DropdownMenuItem(
                    value: SenderSort.byDate,
                    child: Text('By Date'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) provider.setSort(v);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: senders.isEmpty
              ? const Center(child: Text('No senders found'))
              : ListView.builder(
                  itemCount: senders.length,
                  itemBuilder: (context, index) {
                    final sender = senders[index];
                    return SenderTile(
                      sender: sender,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SenderDetailScreen(email: sender.email),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
