/// 06_BACKEND.md §2 `users/{uid}/mail/{mailId}`의 화면용 사본.
class MailItem {
  const MailItem({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.attachments,
    required this.claimed,
    this.expireAt,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final List<({String item, int amount})> attachments;
  final bool claimed;
  final DateTime? expireAt;

  bool isExpired(DateTime now) => expireAt != null && now.isAfter(expireAt!);
}
