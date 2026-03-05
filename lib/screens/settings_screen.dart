import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/scan_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Account', style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(auth.account?.email ?? 'Not connected'),
            subtitle: Text(auth.account?.displayHost ?? ''),
          ),
          const Divider(),
          // Actions
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rescan Inbox'),
            onTap: () {
              context.read<ScanProvider>().reset();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Logout',
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}
