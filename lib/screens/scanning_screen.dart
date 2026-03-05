import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import '../widgets/scan_progress_indicator.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();

    if (scan.state == ScanState.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(scan.errorMessage ?? 'Scan failed'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => scan.startScan(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: ScanProgressIndicator(
          fetched: scan.fetched,
          total: scan.total,
          progress: scan.progress,
        ),
      ),
    );
  }
}
