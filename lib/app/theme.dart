import 'package:flutter/material.dart';

/// 05_FRONTEND.md §2 "팔레트 테마". 태그 카테고리 색(§6)의 TEMPER 팔레트
/// (해/달/들)를 골자로 한 따뜻한 숲 캠프 분위기 — 별도 브랜드 컬러가
/// 기획서에 없어 이미 정의된 팔레트에서 시드를 고른다.
const Color _seedColor = Color(0xFFF2C14E); // TEMPER 해
const Color _campfireColor = Color(0xFFE8734A); // ELEMENT 불

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    secondary: _campfireColor,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: colorScheme.surface, foregroundColor: colorScheme.onSurface),
  );
}
