import 'package:flutter/foundation.dart';

import '../models/email_category.dart';
import '../models/email_message.dart';
import '../models/scan_result.dart';

class CategoryProvider extends ChangeNotifier {
  Map<EmailCategory, CategorySummary> _categories = {};
  final Set<int> _selectedUids = {};

  Map<EmailCategory, CategorySummary> get categories => _categories;
  Set<int> get selectedUids => _selectedUids;

  void updateFromScan(ScanResult result) {
    _categories = result.categories;
    _selectedUids.clear();
    notifyListeners();
  }

  CategorySummary? getCategory(EmailCategory category) => _categories[category];

  List<EmailMessage> messagesFor(EmailCategory category) =>
      _categories[category]?.messages ?? [];

  void toggleSelection(int uid) {
    if (_selectedUids.contains(uid)) {
      _selectedUids.remove(uid);
    } else {
      _selectedUids.add(uid);
    }
    notifyListeners();
  }

  void selectAll(EmailCategory category) {
    final msgs = messagesFor(category);
    _selectedUids.addAll(msgs.map((m) => m.uid));
    notifyListeners();
  }

  void deselectAll() {
    _selectedUids.clear();
    notifyListeners();
  }

  bool isSelected(int uid) => _selectedUids.contains(uid);
}
