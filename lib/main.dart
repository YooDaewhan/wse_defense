import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await signInAnonymouslyIfNeeded();
  runApp(WseDefenseApp(router: buildAppRouter()));
}

class WseDefenseApp extends StatelessWidget {
  const WseDefenseApp({super.key, required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WSE Defense',
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
