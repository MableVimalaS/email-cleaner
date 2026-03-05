import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:email_cleaner_server/imap_handler.dart';

final _manager = ImapSessionManager();

void main() async {
  final router = Router();

  // Health check
  router.get('/health', (_) => Response.ok('ok'));

  // POST /connect
  // Body: { sessionId, host, port, useSsl, email, password }
  router.post('/connect', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      await _manager.connect(
        sessionId: body['sessionId'] as String,
        host: body['host'] as String,
        port: body['port'] as int,
        useSsl: body['useSsl'] as bool? ?? true,
        email: body['email'] as String,
        password: body['password'] as String,
      );
      return Response.ok(jsonEncode({'status': 'connected'}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // POST /disconnect
  // Body: { sessionId }
  router.post('/disconnect', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      await _manager.disconnect(body['sessionId'] as String);
      return Response.ok(jsonEncode({'status': 'disconnected'}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // GET /inbox?sessionId=...
  router.get('/inbox', (Request req) async {
    try {
      final sessionId = req.url.queryParameters['sessionId']!;
      final count = await _manager.selectInbox(sessionId);
      return Response.ok(jsonEncode({'count': count}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // GET /messages?sessionId=...&start=...&end=...
  router.get('/messages', (Request req) async {
    try {
      final params = req.url.queryParameters;
      final sessionId = params['sessionId']!;
      final start = int.parse(params['start']!);
      final end = int.parse(params['end']!);
      final messages =
          await _manager.fetchMessages(sessionId, start: start, end: end);
      return Response.ok(jsonEncode({'messages': messages}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // POST /delete
  // Body: { sessionId, uids: [int] }
  router.post('/delete', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final sessionId = body['sessionId'] as String;
      final uids = (body['uids'] as List).cast<int>();
      await _manager.deleteMessages(sessionId, uids);
      return Response.ok(jsonEncode({'status': 'deleted', 'count': uids.length}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // GET /search/unseen?sessionId=...
  router.get('/search/unseen', (Request req) async {
    try {
      final sessionId = req.url.queryParameters['sessionId']!;
      final uids = await _manager.searchUnseen(sessionId);
      return Response.ok(jsonEncode({'uids': uids}),
          headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}), headers: _jsonHeaders);
    }
  });

  // Add CORS middleware so browser can call us
  final handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8081;
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('IMAP proxy server running on http://localhost:${server.port}');
}

const _jsonHeaders = {'Content-Type': 'application/json'};
