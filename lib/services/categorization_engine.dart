import '../models/email_category.dart';
import '../models/email_message.dart';
import '../utils/email_patterns.dart';
import '../utils/constants.dart';

class CategorizationEngine {
  EmailCategory categorize(EmailMessage message) {
    final scores = <EmailCategory, double>{};

    for (final cat in EmailCategory.values) {
      scores[cat] = 0;
    }

    _scoreByHeaders(message, scores);
    _scoreBySenderDomain(message, scores);
    _scoreBySenderPrefix(message, scores);
    _scoreBySubject(message, scores);

    // Find highest scoring category above threshold
    EmailCategory best = EmailCategory.other;
    double bestScore = 0;

    for (final entry in scores.entries) {
      if (entry.key != EmailCategory.other && entry.value > bestScore) {
        bestScore = entry.value;
        best = entry.key;
      }
    }

    return bestScore >= AppConstants.categoryScoreThreshold
        ? best
        : EmailCategory.other;
  }

  void _scoreByHeaders(
      EmailMessage message, Map<EmailCategory, double> scores) {
    if (message.listUnsubscribe != null) {
      scores[EmailCategory.newsletters] =
          scores[EmailCategory.newsletters]! + 1.5;
      scores[EmailCategory.promotions] =
          scores[EmailCategory.promotions]! + 1.0;
    }

    final headers = message.headers;

    if (headers.containsKey('X-Campaign-Id')) {
      scores[EmailCategory.promotions] =
          scores[EmailCategory.promotions]! + 2.0;
    }

    final spamFlag = headers['X-Spam-Flag']?.toLowerCase();
    if (spamFlag == 'yes' || spamFlag == 'true') {
      scores[EmailCategory.spam] = scores[EmailCategory.spam]! + 3.0;
    }

    final precedence = headers['Precedence']?.toLowerCase();
    if (precedence == 'bulk' || precedence == 'list') {
      scores[EmailCategory.newsletters] =
          scores[EmailCategory.newsletters]! + 1.0;
    }
  }

  void _scoreBySenderDomain(
      EmailMessage message, Map<EmailCategory, double> scores) {
    final domain = message.domain;

    for (final socialDomain in EmailPatterns.socialDomains) {
      if (domain == socialDomain || domain.endsWith('.$socialDomain')) {
        scores[EmailCategory.social] = scores[EmailCategory.social]! + 3.0;
        return;
      }
    }
  }

  void _scoreBySenderPrefix(
      EmailMessage message, Map<EmailCategory, double> scores) {
    final localPart = message.senderEmail.split('@').first.toLowerCase();

    for (final prefix in EmailPatterns.promoPrefixes) {
      if (localPart.startsWith(prefix)) {
        scores[EmailCategory.promotions] =
            scores[EmailCategory.promotions]! + 1.5;
        break;
      }
    }

    for (final prefix in EmailPatterns.bulkPrefixes) {
      if (localPart.startsWith(prefix)) {
        scores[EmailCategory.newsletters] =
            scores[EmailCategory.newsletters]! + 1.0;
        break;
      }
    }
  }

  void _scoreBySubject(
      EmailMessage message, Map<EmailCategory, double> scores) {
    final subject = message.subject.toLowerCase();

    _scoreTerms(subject, EmailPatterns.promoSubjectTerms,
        scores, EmailCategory.promotions, 1.0);
    _scoreTerms(subject, EmailPatterns.socialSubjectTerms,
        scores, EmailCategory.social, 1.5);
    _scoreTerms(subject, EmailPatterns.newsletterSubjectTerms,
        scores, EmailCategory.newsletters, 1.5);
    _scoreTerms(subject, EmailPatterns.spamTerms,
        scores, EmailCategory.spam, 1.5);
    _scoreTerms(subject, EmailPatterns.updateSubjectTerms,
        scores, EmailCategory.updates, 1.5);
  }

  void _scoreTerms(
    String text,
    List<String> terms,
    Map<EmailCategory, double> scores,
    EmailCategory category,
    double weight,
  ) {
    for (final term in terms) {
      if (text.contains(term.toLowerCase())) {
        scores[category] = scores[category]! + weight;
      }
    }
  }
}
