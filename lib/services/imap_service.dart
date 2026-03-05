import 'package:enough_mail/enough_mail.dart';

import '../models/account_config.dart';
import '../models/email_message.dart';
import 'imap_service_interface.dart';

class ImapService implements ImapServiceInterface {
  ImapClient? _client;
  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(AccountConfig config) async {
    _client = ImapClient(isLogEnabled: false);
    await _client!.connectToServer(
      config.displayHost,
      config.displayPort,
      isSecure: config.useSsl,
    );
    await _client!.login(config.email, config.password);
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    if (_client != null && _isConnected) {
      try {
        await _client!.logout();
      } catch (_) {}
      _isConnected = false;
      _client = null;
    }
  }

  @override
  Future<int> selectInbox() async {
    _ensureConnected();
    final mailbox = await _client!.selectInbox();
    return mailbox.messagesExists;
  }

  @override
  Future<List<EmailMessage>> fetchMessages({
    required int start,
    required int end,
  }) async {
    _ensureConnected();
    if (start > end) return [];

    final sequence = MessageSequence.fromRange(start, end, isUidSequence: true);
    final fetchResult = await _client!.uidFetchMessages(
      sequence,
      '(UID ENVELOPE RFC822.SIZE BODY.PEEK[HEADER.FIELDS (List-Unsubscribe X-Campaign-Id X-Spam-Flag Precedence X-Mailer)])',
    );

    return fetchResult.messages.map(_convertMessage).toList();
  }

  EmailMessage _convertMessage(MimeMessage mime) {
    final from = mime.from?.isNotEmpty == true ? mime.from!.first : null;

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

    return EmailMessage(
      uid: mime.uid ?? 0,
      subject: mime.decodeSubject() ?? '(no subject)',
      senderEmail: from?.email ?? 'unknown',
      senderName: from?.personalName ?? from?.email ?? 'Unknown',
      date: mime.decodeDate() ?? DateTime.now(),
      size: mime.size ?? 0,
      listUnsubscribe: headers['List-Unsubscribe'],
      headers: headers,
    );
  }

  @override
  Future<void> deleteMessages(List<int> uids) async {
    _ensureConnected();
    if (uids.isEmpty) return;

    final sequence = MessageSequence.fromIds(uids, isUid: true);
    await _client!.uidStore(sequence, [MessageFlags.deleted]);
    await _client!.expunge();
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
    _ensureConnected();
    final result = await _client!.searchMessages(searchCriteria: 'UNSEEN');
    return result.matchingSequence?.toList() ?? [];
  }

  void _ensureConnected() {
    if (_client == null || !_isConnected) {
      throw StateError('Not connected to IMAP server');
    }
  }
}
