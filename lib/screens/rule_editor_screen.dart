import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cleanup_rule.dart';
import '../providers/rules_provider.dart';

class RuleEditorScreen extends StatefulWidget {
  final CleanupRule? existingRule;

  const RuleEditorScreen({super.key, this.existingRule});

  @override
  State<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends State<RuleEditorScreen> {
  RuleField _field = RuleField.sender;
  RuleOperator _operator = RuleOperator.contains;
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      _field = widget.existingRule!.field;
      _operator = widget.existingRule!.operator;
      _valueController.text = widget.existingRule!.value;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  List<RuleOperator> get _validOperators {
    switch (_field) {
      case RuleField.sender:
      case RuleField.subject:
        return [RuleOperator.contains, RuleOperator.equals];
      case RuleField.age:
      case RuleField.size:
        return [RuleOperator.greaterThan, RuleOperator.lessThan];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRule != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Rule' : 'New Rule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<RuleField>(
              initialValue: _field,
              decoration: const InputDecoration(labelText: 'Field'),
              items: RuleField.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.name),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _field = v;
                    if (!_validOperators.contains(_operator)) {
                      _operator = _validOperators.first;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RuleOperator>(
              initialValue: _validOperators.contains(_operator)
                  ? _operator
                  : _validOperators.first,
              decoration: const InputDecoration(labelText: 'Operator'),
              items: _validOperators
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(switch (o) {
                          RuleOperator.contains => 'contains',
                          RuleOperator.equals => 'equals',
                          RuleOperator.greaterThan => 'greater than',
                          RuleOperator.lessThan => 'less than',
                        }),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _operator = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Value',
                hintText: switch (_field) {
                  RuleField.sender => 'e.g. noreply@example.com',
                  RuleField.subject => 'e.g. newsletter',
                  RuleField.age => 'days (e.g. 30)',
                  RuleField.size => 'KB (e.g. 500)',
                },
              ),
              keyboardType: (_field == RuleField.age || _field == RuleField.size)
                  ? TextInputType.number
                  : TextInputType.text,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Rule' : 'Create Rule'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final value = _valueController.text.trim();
    if (value.isEmpty) return;

    final rule = CleanupRule(
      id: widget.existingRule?.id,
      field: _field,
      operator: _operator,
      value: value,
    );

    final provider = context.read<RulesProvider>();
    if (widget.existingRule != null) {
      provider.updateRule(rule);
    } else {
      provider.addRule(rule);
    }

    Navigator.pop(context);
  }
}
