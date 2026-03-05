import 'email_message.dart';

class EmailSender {
  final String email;
  final String name;
  final List<EmailMessage> messages;

  EmailSender({
    required this.email,
    required this.name,
    List<EmailMessage>? messages,
  }) : messages = messages ?? [];

  int get messageCount => messages.length;

  int get totalSize => messages.fold(0, (sum, m) => sum + m.size);

  DateTime? get latestDate {
    if (messages.isEmpty) return null;
    return messages.map((m) => m.date).reduce(
      (a, b) => a.isAfter(b) ? a : b,
    );
  }

  DateTime? get oldestDate {
    if (messages.isEmpty) return null;
    return messages.map((m) => m.date).reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
  }

  bool get hasUnsubscribe => messages.any((m) => m.hasUnsubscribe);

  String? get unsubscribeUrl {
    for (final m in messages) {
      if (m.unsubscribeUrl != null) return m.unsubscribeUrl;
    }
    return null;
  }

  List<int> get uids => messages.map((m) => m.uid).toList();

  String get domain {
    final parts = email.split('@');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  @override
  String toString() => 'EmailSender($email, ${messages.length} msgs)';
}
