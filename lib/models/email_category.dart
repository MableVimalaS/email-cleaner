import 'package:flutter/material.dart';

import 'email_message.dart';

enum EmailCategory {
  promotions(Icons.local_offer, Colors.orange, 'Promotions'),
  social(Icons.people, Colors.blue, 'Social'),
  newsletters(Icons.article, Colors.green, 'Newsletters'),
  spam(Icons.report, Colors.red, 'Spam'),
  updates(Icons.notifications, Colors.purple, 'Updates'),
  other(Icons.mail, Colors.grey, 'Other');

  final IconData icon;
  final Color color;
  final String label;

  const EmailCategory(this.icon, this.color, this.label);
}

class CategorySummary {
  final EmailCategory category;
  final List<EmailMessage> messages;

  CategorySummary({required this.category, List<EmailMessage>? messages})
      : messages = messages ?? [];

  int get count => messages.length;

  int get totalSize => messages.fold(0, (sum, m) => sum + m.size);

  List<int> get uids => messages.map((m) => m.uid).toList();
}
