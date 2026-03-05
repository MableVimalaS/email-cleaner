import 'package:enough_mail/enough_mail.dart';

/// Holds one IMAP session per session token.
class ImapSessionManager {
  final _sessions = <String, ImapClient>{};

  Future<void> connect({
    required String sessionId,
    required String host,
    required int port,
    required bool useSsl,
    required String email,
    required String password,
  }) async {
    // Disconnect existing session if any
    await disconnect(sessionId);

    final client = ImapClient(isLogEnabled: false);
    await client.connectToServer(host, port, isSecure: useSsl);
    await client.login(email, password);
    _sessions[sessionId] = client;
  }

  Future<void> disconnect(String sessionId) async {
    final client = _sessions.remove(sessionId);
    if (client != null) {
      try {
        await client.logout();
      } catch (_) {}
    }
  }

  ImapClient _get(String sessionId) {
    final client = _sessions[sessionId];
    if (client == null) {
      throw StateError('No IMAP session for $sessionId');
    }
    return client;
  }

  Future<int> selectInbox(String sessionId) async {
    final client = _get(sessionId);
    final mailbox = await client.selectInbox();
    return mailbox.messagesExists;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
    String sessionId, {
    required int start,
    required int end,
  }) async {
    final client = _get(sessionId);
    if (start > end) return [];

    final sequence =
        MessageSequence.fromRange(start, end, isUidSequence: false);
    final fetchResult = await client.fetchMessages(
      sequence,
      '(UID ENVELOPE RFC822.SIZE BODY.PEEK[HEADER.FIELDS '
          '(List-Unsubscribe X-Campaign-Id X-Spam-Flag Precedence X-Mailer)])',
    );

    return fetchResult.messages.map(_mimeToJson).toList();
  }

  Map<String, dynamic> _mimeToJson(MimeMessage mime) {
    final from =
        mime.from?.isNotEmpty == true ? mime.from!.first : null;

    final headers = <String, String>{};
    for (final name in [
      'List-Unsubscribe',
      'X-Campaign-Id',
      'X-Spam-Flag',
      'Precedence',
      'X-Mailer',
    ]) {
      final value = mime.decodeHeaderValue(name);
      if (value != null) headers[name] = value;
    }

    return {
      'uid': mime.uid ?? 0,
      'subject': mime.decodeSubject() ?? '(no subject)',
      'senderEmail': from?.email ?? 'unknown',
      'senderName': from?.personalName ?? from?.email ?? 'Unknown',
      'date': (mime.decodeDate() ?? DateTime.now()).toIso8601String(),
      'size': mime.size ?? 0,
      'listUnsubscribe': headers['List-Unsubscribe'],
      'headers': headers,
    };
  }

  Future<void> deleteMessages(String sessionId, List<int> uids) async {
    final client = _get(sessionId);
    if (uids.isEmpty) return;

    final sequence = MessageSequence.fromIds(uids, isUid: true);
    await client.uidStore(sequence, [MessageFlags.deleted]);
    await client.expunge();
  }

  Future<List<int>> searchUnseen(String sessionId) async {
    final client = _get(sessionId);
    final result =
        await client.searchMessages(searchCriteria: 'UNSEEN');
    return result.matchingSequence?.toList() ?? [];
  }

  bool hasSession(String sessionId) => _sessions.containsKey(sessionId);
}
