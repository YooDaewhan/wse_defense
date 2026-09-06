import 'package:flutter/material.dart';

import '../../../domain/mail/mail_item.dart';

/// 05_FRONTEND.md §2 `/mail`: 첨부 우편 목록 + 수령. 만료/이미 수령한
/// 우편은 버튼이 비활성화된다.
class MailScreen extends StatelessWidget {
  const MailScreen({super.key, required this.mail, required this.onClaimTap, required this.now});

  final List<MailItem> mail;
  final void Function(String mailId) onClaimTap;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('우편')),
      body: mail.isEmpty
          ? const Center(child: Text('받은 우편이 없습니다', key: ValueKey('mail_empty')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in mail)
                  Card(
                    key: ValueKey('mail_item_${item.id}'),
                    child: ListTile(
                      title: Text(item.titleKey),
                      subtitle: Text(
                        '${item.bodyKey}\n${item.attachments.map((a) => '${a.item}×${a.amount}').join(', ')}',
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        key: ValueKey('mail_claim_${item.id}'),
                        onPressed: item.claimed || item.isExpired(now) ? null : () => onClaimTap(item.id),
                        child: Text(item.claimed ? '수령함' : (item.isExpired(now) ? '만료됨' : '수령')),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
