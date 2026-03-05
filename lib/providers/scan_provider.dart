import 'package:flutter/foundation.dart';

import '../models/cleanup_rule.dart';
import '../models/scan_result.dart';
import '../services/email_scanner.dart';

enum ScanState { idle, scanning, done, error }

class ScanProvider extends ChangeNotifier {
  final EmailScanner _scanner;

  ScanState _state = ScanState.idle;
  ScanResult? _result;
  int _fetched = 0;
  int _total = 0;
  String? _errorMessage;

  ScanProvider(this._scanner);

  ScanState get state => _state;
  ScanResult? get result => _result;
  int get fetched => _fetched;
  int get total => _total;
  double get progress => _total > 0 ? _fetched / _total : 0;
  String? get errorMessage => _errorMessage;

  Future<void> startScan({List<CleanupRule> rules = const []}) async {
    _state = ScanState.scanning;
    _fetched = 0;
    _total = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _scanner.scan(
        rules: rules,
        onProgress: (fetched, total) {
          _fetched = fetched;
          _total = total;
          notifyListeners();
        },
      );
      _state = ScanState.done;
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _state = ScanState.idle;
    _result = null;
    _fetched = 0;
    _total = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
