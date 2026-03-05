import 'package:flutter/foundation.dart';

import '../services/imap_service_interface.dart';

enum CleanupState { idle, deleting, done, error }

class CleanupProvider extends ChangeNotifier {
  final ImapServiceInterface _imapService;

  CleanupState _state = CleanupState.idle;
  int _deleted = 0;
  int _total = 0;
  String? _errorMessage;
  List<int> _lastDeletedUids = [];

  CleanupProvider(this._imapService);

  CleanupState get state => _state;
  int get deleted => _deleted;
  int get total => _total;
  double get progress => _total > 0 ? _deleted / _total : 0;
  String? get errorMessage => _errorMessage;
  List<int> get lastDeletedUids => _lastDeletedUids;

  Future<void> deleteMessages(List<int> uids) async {
    if (uids.isEmpty) return;

    _state = CleanupState.deleting;
    _deleted = 0;
    _total = uids.length;
    _errorMessage = null;
    _lastDeletedUids = List.from(uids);
    notifyListeners();

    try {
      await _imapService.deleteMessagesChunked(
        uids,
        onProgress: (deleted, total) {
          _deleted = deleted;
          _total = total;
          notifyListeners();
        },
      );
      _state = CleanupState.done;
    } catch (e) {
      _state = CleanupState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _state = CleanupState.idle;
    _deleted = 0;
    _total = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
