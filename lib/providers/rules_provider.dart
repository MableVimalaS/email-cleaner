import 'package:flutter/foundation.dart';

import '../models/cleanup_rule.dart';
import '../services/storage_service.dart';

class RulesProvider extends ChangeNotifier {
  final StorageService _storage;
  List<CleanupRule> _rules = [];

  RulesProvider(this._storage);

  List<CleanupRule> get rules => List.unmodifiable(_rules);

  Future<void> loadRules() async {
    _rules = await _storage.loadRules();
    notifyListeners();
  }

  Future<void> addRule(CleanupRule rule) async {
    _rules.add(rule);
    await _storage.saveRules(_rules);
    notifyListeners();
  }

  Future<void> updateRule(CleanupRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index >= 0) {
      _rules[index] = rule;
      await _storage.saveRules(_rules);
      notifyListeners();
    }
  }

  Future<void> removeRule(String id) async {
    _rules.removeWhere((r) => r.id == id);
    await _storage.saveRules(_rules);
    notifyListeners();
  }

  Future<void> toggleRule(String id) async {
    final rule = _rules.firstWhere((r) => r.id == id);
    rule.enabled = !rule.enabled;
    await _storage.saveRules(_rules);
    notifyListeners();
  }
}
