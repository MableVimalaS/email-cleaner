class AccountConfig {
  final String email;
  final String password;
  final String? imapHost;
  final int? imapPort;
  final bool useSsl;

  AccountConfig({
    required this.email,
    required this.password,
    this.imapHost,
    this.imapPort,
    this.useSsl = true,
  });

  bool get isManualConfig => imapHost != null && imapHost!.isNotEmpty;

  String get displayHost => imapHost ?? _guessHost();

  int get displayPort => imapPort ?? (useSsl ? 993 : 143);

  String _guessHost() {
    final domain = email.split('@').last.toLowerCase();
    return 'imap.$domain';
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'imapHost': imapHost,
        'imapPort': imapPort,
        'useSsl': useSsl,
      };

  factory AccountConfig.fromJson(Map<String, dynamic> json, String password) =>
      AccountConfig(
        email: json['email'] as String,
        password: password,
        imapHost: json['imapHost'] as String?,
        imapPort: json['imapPort'] as int?,
        useSsl: json['useSsl'] as bool? ?? true,
      );
}
