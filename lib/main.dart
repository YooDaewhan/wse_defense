import 'package:flutter/material.dart';

void main() {
  runApp(const WseDefenseApp());
}

class WseDefenseApp extends StatelessWidget {
  const WseDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'WSE Defense',
      home: Scaffold(body: SizedBox.shrink()),
    );
  }
}
