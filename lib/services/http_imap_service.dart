import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/account_config.dart';
import '../models/email_message.dart';
import 'imap_service_interface.dart';

/// IMAP service that talks to the backend proxy server via HTTP.
/// Used on Flutter Web where raw TCP sockets are unavailable.
///
/// Architecture:
///   Browser (Flutter Web) --HTTPS--> Backend Server --TCP--> Mail Server
class HttpImapService implements ImapServiceInterface {
  final String _baseUrl;
  final String _sessionId = const Uuid().v4();
  bool _isConnected = false;

  HttpImapService({String? baseUrl})
      : _baseUrl = baseUrl ??
            const String.fromEnvironment('BACKEND_URL',
                defaultValue: 'http://localhost:8081');

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(AccountConfig config) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/connect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': _sessionId,
        'host': config.displayHost,
        'port': config.displayPort,
        'useSsl': config.useSsl,
        'email': config.email,
        'password': config.password,
      }),
    );
    _checkResponse(response);
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/disconnect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': _sessionId}),
      );
    } catch (_) {}
    _isConnected = false;
  }

  @override
  Future<int> selectInbox() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/inbox?sessionId=$_sessionId'),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['count'] as int;
  }

  @override
  Future<List<EmailMessage>> fetchMessages({
    required int start,
    required int end,
  }) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/messages?sessionId=$_sessionId&start=$start&end=$end'),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['messages'] as List;
    return list.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> deleteMessages(List<int> uids) async {
    if (uids.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_baseUrl/delete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': _sessionId,
        'uids': uids,
      }),
    );
    _checkResponse(response);
  }

  @override
  Future<void> deleteMessagesChunked(
    List<int> uids, {
    int chunkSize = 200,
    void Function(int deleted, int total)? onProgress,
  }) async {
    for (var i = 0; i < uids.length; i += chunkSize) {
      final end = (i + chunkSize < uids.length) ? i + chunkSize : uids.length;
      final chunk = uids.sublist(i, end);
      await deleteMessages(chunk);
      onProgress?.call(end, uids.length);
    }
  }

  @override
  Future<List<int>> searchUnseen() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/unseen?sessionId=$_sessionId'),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['uids'] as List).cast<int>();
  }

  EmailMessage _fromJson(Map<String, dynamic> json) {
    return EmailMessage(
      uid: json['uid'] as int,
      subject: json['subject'] as String,
      senderEmail: json['senderEmail'] as String,
      senderName: json['senderName'] as String,
      date: DateTime.parse(json['date'] as String),
      size: json['size'] as int? ?? 0,
      listUnsubscribe: json['listUnsubscribe'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? 'Server error ${response.statusCode}');
    }
  }
}
