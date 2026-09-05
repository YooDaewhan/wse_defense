import 'package:flutter/material.dart';

/// 09_MILESTONES.md T-28: "모든 라우트 진입 가능(빈 화면 허용)". 아직
/// 구현되지 않은 화면은 이 위젯 하나로 채워 라우팅부터 먼저 완성한다.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          subtitle ?? '준비 중입니다',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
