class EmailMessage {
  final int uid;
  final String subject;
  final String senderEmail;
  final String senderName;
  final DateTime date;
  final int size;
  final String? listUnsubscribe;
  final Map<String, String> headers;
  final String? bodyPreview;

  EmailMessage({
    required this.uid,
    required this.subject,
    required this.senderEmail,
    required this.senderName,
    required this.date,
    this.size = 0,
    this.listUnsubscribe,
    this.headers = const {},
    this.bodyPreview,
  });

  String get senderKey => senderEmail.toLowerCase();

  String get domain {
    final parts = senderEmail.split('@');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get hasUnsubscribe => listUnsubscribe != null && listUnsubscribe!.isNotEmpty;

  String? get unsubscribeUrl {
    if (listUnsubscribe == null) return null;
    final match = RegExp(r'<(https?://[^>]+)>').firstMatch(listUnsubscribe!);
    return match?.group(1);
  }

  int get ageDays => DateTime.now().difference(date).inDays;

  @override
  String toString() => 'EmailMessage(uid: $uid, from: $senderEmail, subject: $subject)';
}
