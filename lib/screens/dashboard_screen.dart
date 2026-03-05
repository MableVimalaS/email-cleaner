import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/email_category.dart';
import '../providers/category_provider.dart';
import '../providers/scan_provider.dart';
import '../providers/sender_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/stat_chip.dart';
import 'category_detail_screen.dart';
import 'rules_screen.dart';
import 'sender_list_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scan = context.read<ScanProvider>();
      if (scan.result != null) {
        context.read<CategoryProvider>().updateFromScan(scan.result!);
        context.read<SenderProvider>().updateFromScan(scan.result!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Cleaner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _rescan,
            tooltip: 'Rescan',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _CategoriesTab(),
          SenderListScreen(),
          RulesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Senders',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule),
            label: 'Rules',
          ),
        ],
      ),
    );
  }

  void _rescan() {
    context.read<ScanProvider>().reset();
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final categories = context.watch<CategoryProvider>();
    final result = scan.result;

    if (result == null) {
      return const Center(child: Text('No scan data'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: StatChip(
                icon: Icons.email,
                label: 'Emails',
                value: '${result.totalCount}',
              ),
            ),
            Expanded(
              child: StatChip(
                icon: Icons.people,
                label: 'Senders',
                value: '${result.senderCount}',
              ),
            ),
            Expanded(
              child: StatChip(
                icon: Icons.storage,
                label: 'Size',
                value: _formatSize(result.totalSize),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Category cards
        ...EmailCategory.values
            .map((cat) => categories.getCategory(cat))
            .where((s) => s != null && s.count > 0)
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CategoryCard(
                    summary: s!,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryDetailScreen(category: s.category),
                      ),
                    ),
                  ),
                )),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
