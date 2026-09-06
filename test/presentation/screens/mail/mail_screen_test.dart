import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/mail/mail_item.dart';
import 'package:wse_defense/presentation/screens/mail/mail_screen.dart';

final _now = DateTime.utc(2026, 1, 1);

void main() {
  testWidgets('shows an empty hint with no mail', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MailScreen(mail: const [], onClaimTap: (_) {}, now: _now)));

    expect(find.byKey(const ValueKey('mail_empty')), findsOneWidget);
  });

  testWidgets('tapping claim on an unclaimed, unexpired mail reports its id', (tester) async {
    String? claimed;
    final mail = [
      const MailItem(id: 'MAIL_1', titleKey: 'mail.test', bodyKey: 'mail.test.body', attachments: [(item: 'ITM_GOLD', amount: 150)], claimed: false),
    ];
    await tester.pumpWidget(MaterialApp(home: MailScreen(mail: mail, onClaimTap: (id) => claimed = id, now: _now)));

    await tester.tap(find.byKey(const ValueKey('mail_claim_MAIL_1')));
    await tester.pump();

    expect(claimed, 'MAIL_1');
  });

  testWidgets('an already-claimed mail has a disabled button', (tester) async {
    final mail = [
      const MailItem(id: 'MAIL_1', titleKey: 'mail.test', bodyKey: 'mail.test.body', attachments: [], claimed: true),
    ];
    await tester.pumpWidget(MaterialApp(home: MailScreen(mail: mail, onClaimTap: (_) {}, now: _now)));

    final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('mail_claim_MAIL_1')));
    expect(button.onPressed, isNull);
  });

  testWidgets('an expired mail has a disabled button even if unclaimed', (tester) async {
    final mail = [
      MailItem(
        id: 'MAIL_1',
        titleKey: 'mail.test',
        bodyKey: 'mail.test.body',
        attachments: const [],
        claimed: false,
        expireAt: _now.subtract(const Duration(days: 1)),
      ),
    ];
    await tester.pumpWidget(MaterialApp(home: MailScreen(mail: mail, onClaimTap: (_) {}, now: _now)));

    final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('mail_claim_MAIL_1')));
    expect(button.onPressed, isNull);
  });
}
