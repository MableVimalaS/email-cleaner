import '../models/email_category.dart';
import '../models/email_message.dart';
import '../models/email_sender.dart';
import '../models/cleanup_rule.dart';
import '../models/scan_result.dart';
import '../utils/constants.dart';
import 'imap_service_interface.dart';
import 'categorization_engine.dart';

class EmailScanner {
  final ImapServiceInterface _imapService;
  final CategorizationEngine _categorizer = CategorizationEngine();

  EmailScanner(this._imapService);

  Future<ScanResult> scan({
    List<CleanupRule> rules = const [],
    void Function(int fetched, int total)? onProgress,
  }) async {
    final totalCount = await _imapService.selectInbox();
    if (totalCount == 0) return ScanResult.empty();

    final allMessages = <EmailMessage>[];
    final batchSize = AppConstants.fetchBatchSize;

    // Fetch in batches using UID ranges
    for (var i = 1; i <= totalCount; i += batchSize) {
      final end = (i + batchSize - 1 < totalCount)
          ? i + batchSize - 1
          : totalCount;
      try {
        final batch = await _imapService.fetchMessages(start: i, end: end);
        allMessages.addAll(batch);
      } catch (_) {
        // Skip failed batches
      }
      onProgress?.call(allMessages.length, totalCount);
    }

    // Categorize
    final categories = <EmailCategory, CategorySummary>{};
    for (final cat in EmailCategory.values) {
      categories[cat] = CategorySummary(category: cat);
    }

    for (final message in allMessages) {
      final category = _categorizer.categorize(message);
      categories[category]!.messages.add(message);
    }

    // Group by sender
    final senders = <String, EmailSender>{};
    for (final message in allMessages) {
      final key = message.senderKey;
      if (!senders.containsKey(key)) {
        senders[key] = EmailSender(
          email: message.senderEmail,
          name: message.senderName,
        );
      }
      senders[key]!.messages.add(message);
    }

    // Apply rules
    final ruleMatches = <EmailMessage>[];
    final enabledRules = rules.where((r) => r.enabled).toList();
    if (enabledRules.isNotEmpty) {
      for (final message in allMessages) {
        for (final rule in enabledRules) {
          if (rule.matches(message)) {
            ruleMatches.add(message);
            break;
          }
        }
      }
    }

    return ScanResult(
      allMessages: allMessages,
      categories: categories,
      senders: senders,
      ruleMatches: ruleMatches,
    );
  }
}
