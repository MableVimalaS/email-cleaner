import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../providers/rules_provider.dart';
import 'rule_editor_screen.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RulesProvider>();
    final rules = provider.rules;
    final theme = Theme.of(context);

    return Scaffold(
      body: rules.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.rule,
                      size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No cleanup rules yet',
                      style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Tap + to create a rule',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => provider.removeRule(rule.id),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: SwitchListTile(
                    title: Text(rule.description),
                    value: rule.enabled,
                    onChanged: (_) => provider.toggleRule(rule.id),
                    secondary: const Icon(Icons.rule),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RuleEditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
