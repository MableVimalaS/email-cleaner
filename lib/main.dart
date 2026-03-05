import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/cleanup_provider.dart';
import 'providers/rules_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/sender_provider.dart';
import 'services/email_scanner.dart';
import 'services/http_imap_service.dart';
import 'services/imap_service.dart';
import 'services/imap_service_interface.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  final storageService = StorageService(prefs, secureStorage);

  // On web: use HTTP proxy to backend server (which holds IMAP TCP connections)
  // On native: use direct IMAP TCP sockets
  final ImapServiceInterface imapService =
      kIsWeb ? HttpImapService() : ImapService();
  final emailScanner = EmailScanner(imapService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(imapService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(emailScanner),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SenderProvider()),
        ChangeNotifierProvider(
          create: (_) => RulesProvider(storageService)..loadRules(),
        ),
        ChangeNotifierProvider(
          create: (_) => CleanupProvider(imapService),
        ),
      ],
      child: const EmailCleanerApp(),
    ),
  );
}
