import 'package:uuid/uuid.dart';

import 'email_message.dart';

enum RuleField { sender, subject, age, size }

enum RuleOperator { contains, equals, greaterThan, lessThan }

class CleanupRule {
  final String id;
  final RuleField field;
  final RuleOperator operator;
  final String value;
  bool enabled;

  CleanupRule({
    String? id,
    required this.field,
    required this.operator,
    required this.value,
    this.enabled = true,
  }) : id = id ?? const Uuid().v4();

  bool matches(EmailMessage message) {
    if (!enabled) return false;

    switch (field) {
      case RuleField.sender:
        return _matchString(message.senderEmail);
      case RuleField.subject:
        return _matchString(message.subject);
      case RuleField.age:
        return _matchNumeric(message.ageDays.toDouble());
      case RuleField.size:
        return _matchNumeric(message.size / 1024);
    }
  }

  bool _matchString(String target) {
    final lower = target.toLowerCase();
    final val = value.toLowerCase();
    switch (operator) {
      case RuleOperator.contains:
        return lower.contains(val);
      case RuleOperator.equals:
        return lower == val;
      case RuleOperator.greaterThan:
      case RuleOperator.lessThan:
        return false;
    }
  }

  bool _matchNumeric(double target) {
    final threshold = double.tryParse(value) ?? 0;
    switch (operator) {
      case RuleOperator.greaterThan:
        return target > threshold;
      case RuleOperator.lessThan:
        return target < threshold;
      case RuleOperator.contains:
      case RuleOperator.equals:
        return target == threshold;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'field': field.index,
        'operator': operator.index,
        'value': value,
        'enabled': enabled,
      };

  factory CleanupRule.fromJson(Map<String, dynamic> json) => CleanupRule(
        id: json['id'] as String,
        field: RuleField.values[json['field'] as int],
        operator: RuleOperator.values[json['operator'] as int],
        value: json['value'] as String,
        enabled: json['enabled'] as bool? ?? true,
      );

  String get description {
    final fieldName = field.name;
    final op = switch (operator) {
      RuleOperator.contains => 'contains',
      RuleOperator.equals => 'equals',
      RuleOperator.greaterThan => '>',
      RuleOperator.lessThan => '<',
    };
    final unit = switch (field) {
      RuleField.age => ' days',
      RuleField.size => ' KB',
      _ => '',
    };
    return '$fieldName $op "$value$unit"';
  }
}
