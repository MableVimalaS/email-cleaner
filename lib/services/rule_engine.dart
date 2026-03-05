import '../models/cleanup_rule.dart';
import '../models/email_message.dart';

class RuleEngine {
  List<EmailMessage> evaluate(
    List<CleanupRule> rules,
    List<EmailMessage> messages,
  ) {
    final enabledRules = rules.where((r) => r.enabled).toList();
    if (enabledRules.isEmpty) return [];

    final matches = <EmailMessage>[];
    for (final message in messages) {
      for (final rule in enabledRules) {
        if (rule.matches(message)) {
          matches.add(message);
          break;
        }
      }
    }
    return matches;
  }

  Map<String, List<EmailMessage>> evaluateByRule(
    List<CleanupRule> rules,
    List<EmailMessage> messages,
  ) {
    final result = <String, List<EmailMessage>>{};
    for (final rule in rules.where((r) => r.enabled)) {
      final matches = messages.where((m) => rule.matches(m)).toList();
      if (matches.isNotEmpty) {
        result[rule.id] = matches;
      }
    }
    return result;
  }
}
