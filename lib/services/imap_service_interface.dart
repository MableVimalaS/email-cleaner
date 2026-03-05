import '../models/account_config.dart';
import '../models/email_message.dart';

abstract class ImapServiceInterface {
  bool get isConnected;

  Future<void> connect(AccountConfig config);
  Future<void> disconnect();
  Future<int> selectInbox();

  Future<List<EmailMessage>> fetchMessages({
    required int start,
    required int end,
  });

  Future<void> deleteMessages(List<int> uids);

  Future<void> deleteMessagesChunked(
    List<int> uids, {
    int chunkSize = 200,
    void Function(int deleted, int total)? onProgress,
  });

  Future<List<int>> searchUnseen();
}
