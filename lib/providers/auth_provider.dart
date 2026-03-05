import 'package:flutter/foundation.dart';

import '../models/account_config.dart';
import '../services/imap_service_interface.dart';
import '../services/storage_service.dart';

enum AuthState { loggedOut, connecting, connected, error }

class AuthProvider extends ChangeNotifier {
  final ImapServiceInterface _imapService;
  final StorageService _storageService;

  AuthState _state = AuthState.loggedOut;
  AccountConfig? _account;
  String? _errorMessage;

  AuthProvider(this._imapService, this._storageService);

  AuthState get state => _state;
  AccountConfig? get account => _account;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _state == AuthState.connected;

  Future<void> tryRestoreSession() async {
    final config = await _storageService.loadAccount();
    if (config != null) {
      await login(config);
    }
  }

  Future<void> login(AccountConfig config) async {
    _state = AuthState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      await _imapService.connect(config);
      _account = config;
      _state = AuthState.connected;
      await _storageService.saveAccount(config);
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _imapService.disconnect();
    await _storageService.clearAccount();
    _account = null;
    _state = AuthState.loggedOut;
    _errorMessage = null;
    notifyListeners();
  }
}
