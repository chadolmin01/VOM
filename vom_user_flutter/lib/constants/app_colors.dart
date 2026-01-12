import 'package:flutter/material.dart';

class AppColors {
  // Primary (Toss Blue)
  static const Color primary = Color(0xFF3182F6);
  static const Color primary100 = Color(0xFFD0E8FF);
  static const Color primary500 = Color(0xFF3182F6);

  // Backgrounds
  static const Color background = Color(0xFFF2F4F6); // 토스 특유의 옅은 회색 배경
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF191F28);      // 완전한 검정 대신 짙은 회색

  // Text Colors
  static const Color textPrimary = Color(0xFF191F28);   // 제목, 본문
  static const Color textSecondary = Color(0xFF8B95A1); // 부가 설명
  static const Color textTertiary = Color(0xFFB0B8C1);  // 비활성 텍스트

  // Functional Colors
  static const Color success = Color(0xFF00C853); // 초록 (성공)
  static const Color error = Color(0xFFFF3B30);   // 빨강 (오류/위급)
  static const Color warning = Color(0xFFFFCC00); // 노랑 (주의)

  // UI Elements
  static const Color divider = Color(0xFFE5E8EB);
  static const Color cardShadow = Color(0x0A000000); // 아주 옅은 그림자

  // Gradients (Optional for premium feel)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3182F6), Color(0xFF1B64DA)],
  );
}
