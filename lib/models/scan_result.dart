import 'email_category.dart';
import 'email_message.dart';
import 'email_sender.dart';

class ScanResult {
  final List<EmailMessage> allMessages;
  final Map<EmailCategory, CategorySummary> categories;
  final Map<String, EmailSender> senders;
  final List<EmailMessage> ruleMatches;

  ScanResult({
    required this.allMessages,
    required this.categories,
    required this.senders,
    this.ruleMatches = const [],
  });

  int get totalCount => allMessages.length;

  int get totalSize => allMessages.fold(0, (sum, m) => sum + m.size);

  int get senderCount => senders.length;

  factory ScanResult.empty() => ScanResult(
        allMessages: [],
        categories: {},
        senders: {},
      );
}
