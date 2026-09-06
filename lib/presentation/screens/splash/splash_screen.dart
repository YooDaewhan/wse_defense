import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../../../application/app_scope.dart';

/// 05_FRONTEND.md §2 `/` Splash: "부트스트랩 진행률, 데이터팩 다운로드".
/// 원격 다운로드(T-40)는 아직 없어 번들 데이터팩 로딩 진행률만 보여준다.
/// 10_WIRING_PLAN.md T-56: 로딩 결과는 버리지 않고 [AppScope]에 채운다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.nextRoute = '/camp'});

  final String nextRoute;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await AppScopeProvider.of(context).loadStaticData(
        (path) => rootBundle.loadString('assets/data/v1/$path'),
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (mounted) context.go(widget.nextRoute);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text('로딩 실패: $_error', key: const ValueKey('splash_error')),
            ] else ...[
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(value: _progress, key: const ValueKey('boot_progress')),
              ),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toStringAsFixed(0)}%'),
            ],
          ],
        ),
      ),
    );
  }
}
