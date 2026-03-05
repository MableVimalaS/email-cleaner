import 'dart:math';

import '../models/account_config.dart';
import '../models/email_message.dart';
import 'imap_service_interface.dart';

class DemoImapService implements ImapServiceInterface {
  bool _isConnected = false;
  final _random = Random(42);
  List<EmailMessage>? _generatedMessages;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<void> connect(AccountConfig config) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _generatedMessages = null;
  }

  @override
  Future<int> selectInbox() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _generatedMessages = _generateMessages();
    return _generatedMessages!.length;
  }

  @override
  Future<List<EmailMessage>> fetchMessages({
    required int start,
    required int end,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_generatedMessages == null) return [];
    final s = (start - 1).clamp(0, _generatedMessages!.length);
    final e = end.clamp(0, _generatedMessages!.length);
    return _generatedMessages!.sublist(s, e);
  }

  @override
  Future<void> deleteMessages(List<int> uids) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _generatedMessages?.removeWhere((m) => uids.contains(m.uid));
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
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress?.call(end, uids.length);
    }
  }

  @override
  Future<List<int>> searchUnseen() async {
    return _generatedMessages
            ?.where((m) => m.uid % 3 == 0)
            .map((m) => m.uid)
            .toList() ??
        [];
  }

  List<EmailMessage> _generateMessages() {
    final senders = [
      _S('Amazon', 'deals@amazon.com', 'promotions'),
      _S('Amazon', 'order-update@amazon.com', 'updates'),
      _S('LinkedIn', 'notifications@linkedin.com', 'social'),
      _S('LinkedIn', 'messages-noreply@linkedin.com', 'social'),
      _S('Facebook', 'notification@facebookmail.com', 'social'),
      _S('Twitter', 'notify@x.com', 'social'),
      _S('GitHub', 'notifications@github.com', 'updates'),
      _S('Spotify', 'no-reply@spotify.com', 'promotions'),
      _S('Netflix', 'info@members.netflix.com', 'updates'),
      _S('Medium', 'noreply@medium.com', 'newsletters'),
      _S('Substack', 'newsletter@substack.com', 'newsletters'),
      _S('Morning Brew', 'crew@morningbrew.com', 'newsletters'),
      _S('TLDR', 'dan@tldrnewsletter.com', 'newsletters'),
      _S('Hacker News', 'hn@ycombinator.com', 'newsletters'),
      _S('Nike', 'deals@nike.com', 'promotions'),
      _S('Best Buy', 'offers@bestbuy.com', 'promotions'),
      _S('Target', 'marketing@target.com', 'promotions'),
      _S('Uber', 'noreply@uber.com', 'updates'),
      _S('Google', 'no-reply@accounts.google.com', 'updates'),
      _S('Apple', 'noreply@email.apple.com', 'updates'),
      _S('Dropbox', 'no-reply@dropbox.com', 'updates'),
      _S('Slack', 'feedback@slack.com', 'updates'),
      _S('Wish', 'deals@wish.com', 'spam'),
      _S('Unknown Lottery', 'winner@prize-lottery.xyz', 'spam'),
      _S('Pharmacy Online', 'offers@cheap-meds.biz', 'spam'),
      _S('Alice Johnson', 'alice.johnson@gmail.com', 'other'),
      _S('Bob Smith', 'bob.smith@outlook.com', 'other'),
      _S('Mom', 'mom@gmail.com', 'other'),
    ];

    final promoSubjects = [
      'Flash Sale: Up to 70% off!',
      'Your exclusive coupon inside',
      'Don\'t miss these deals',
      'Limited time offer just for you',
      'Shop now and save big',
      'Free shipping on all orders today',
      'New arrivals you\'ll love',
      'Weekend sale starts now!',
    ];
    final socialSubjects = [
      'commented on your post',
      'sent you a connection request',
      'liked your photo',
      'mentioned you in a comment',
      'You have 5 new notifications',
      'tagged you in a post',
      'sent you a message',
    ];
    final newsletterSubjects = [
      'Weekly Digest: Top Stories',
      'Your Daily Briefing',
      'This Week in Tech - Issue #142',
      'Monthly Roundup: Best of March',
      'The Morning Newsletter',
      'Weekend Reading List',
    ];
    final spamSubjects = [
      'Congratulations! You\'ve won!',
      'Claim your prize now',
      'Act now - urgent response needed',
      'You have been selected as a winner',
      'Amazing deal - buy now!!!',
    ];
    final updateSubjects = [
      'Your order has shipped',
      'Payment receipt',
      'Security alert: new sign-in',
      'Your subscription renewal',
      'Account verification code: 482916',
      'Password reset request',
      'Your monthly statement is ready',
      'Delivery confirmed',
    ];
    final otherSubjects = [
      'Re: Weekend plans?',
      'Dinner on Saturday?',
      'Photos from the trip',
      'Happy Birthday!',
      'Quick question about the project',
    ];

    final messages = <EmailMessage>[];
    final now = DateTime.now();

    for (var i = 0; i < 250; i++) {
      final sender = senders[_random.nextInt(senders.length)];
      final subjects = switch (sender.type) {
        'promotions' => promoSubjects,
        'social' => socialSubjects,
        'newsletters' => newsletterSubjects,
        'spam' => spamSubjects,
        'updates' => updateSubjects,
        _ => otherSubjects,
      };
      final subject = subjects[_random.nextInt(subjects.length)];
      final daysAgo = _random.nextInt(90);
      final hasUnsub =
          sender.type == 'newsletters' || sender.type == 'promotions';

      messages.add(EmailMessage(
        uid: i + 1,
        subject: subject,
        senderEmail: sender.email,
        senderName: sender.name,
        date: now.subtract(Duration(days: daysAgo, hours: _random.nextInt(24))),
        size: 1024 + _random.nextInt(50000),
        listUnsubscribe:
            hasUnsub ? '<https://unsubscribe.example.com/$i>' : null,
        headers: {
          if (hasUnsub)
            'List-Unsubscribe': '<https://unsubscribe.example.com/$i>',
          if (sender.type == 'promotions') 'X-Campaign-Id': 'camp-$i',
          if (sender.type == 'spam') 'X-Spam-Flag': 'YES',
          if (sender.type == 'newsletters') 'Precedence': 'bulk',
        },
      ));
    }

    return messages;
  }
}

class _S {
  final String name;
  final String email;
  final String type;
  _S(this.name, this.email, this.type);
}
