import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account_config.dart';
import '../models/cleanup_rule.dart';
import '../utils/constants.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  StorageService(this._prefs, this._secure);

  // Rules
  Future<List<CleanupRule>> loadRules() async {
    final json = _prefs.getString(AppConstants.prefsRulesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => CleanupRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRules(List<CleanupRule> rules) async {
    final json = jsonEncode(rules.map((r) => r.toJson()).toList());
    await _prefs.setString(AppConstants.prefsRulesKey, json);
  }

  // Account config
  Future<AccountConfig?> loadAccount() async {
    final json = _prefs.getString(AppConstants.prefsAccountKey);
    if (json == null) return null;
    final password =
        await _secure.read(key: AppConstants.securePasswordKey);
    if (password == null) return null;
    return AccountConfig.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
      password,
    );
  }

  Future<void> saveAccount(AccountConfig config) async {
    final json = jsonEncode(config.toJson());
    await _prefs.setString(AppConstants.prefsAccountKey, json);
    await _secure.write(
      key: AppConstants.securePasswordKey,
      value: config.password,
    );
  }

  Future<void> clearAccount() async {
    await _prefs.remove(AppConstants.prefsAccountKey);
    await _secure.delete(key: AppConstants.securePasswordKey);
  }
}
