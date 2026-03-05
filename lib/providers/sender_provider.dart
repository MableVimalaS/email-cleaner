import 'package:flutter/foundation.dart';

import '../models/email_sender.dart';
import '../models/scan_result.dart';

enum SenderSort { byCount, byName, bySize, byDate }

class SenderProvider extends ChangeNotifier {
  Map<String, EmailSender> _senders = {};
  SenderSort _sort = SenderSort.byCount;
  String _searchQuery = '';
  final Set<String> _selectedEmails = {};

  Map<String, EmailSender> get sendersMap => _senders;
  SenderSort get sort => _sort;
  String get searchQuery => _searchQuery;
  Set<String> get selectedEmails => _selectedEmails;

  void updateFromScan(ScanResult result) {
    _senders = result.senders;
    _selectedEmails.clear();
    notifyListeners();
  }

  List<EmailSender> get senders {
    var list = _senders.values.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
          s.email.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q)).toList();
    }

    switch (_sort) {
      case SenderSort.byCount:
        list.sort((a, b) => b.messageCount.compareTo(a.messageCount));
      case SenderSort.byName:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SenderSort.bySize:
        list.sort((a, b) => b.totalSize.compareTo(a.totalSize));
      case SenderSort.byDate:
        list.sort((a, b) {
          final aDate = a.latestDate ?? DateTime(1970);
          final bDate = b.latestDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
    }

    return list;
  }

  void setSort(SenderSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(String email) {
    if (_selectedEmails.contains(email)) {
      _selectedEmails.remove(email);
    } else {
      _selectedEmails.add(email);
    }
    notifyListeners();
  }

  EmailSender? getSender(String email) => _senders[email.toLowerCase()];
}
