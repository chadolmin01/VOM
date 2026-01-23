import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// 1교시 탭: 행동 교실 (Short-form Feed)
/// TODO: 숏폼 피드 기능 구현 예정
class ShortformFeedTab extends StatelessWidget {
  const ShortformFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('1교시: 행동 교실'),
        backgroundColor: AppColors.background,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              '1교시: 행동 교실',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '숏폼 피드 기능이 곧 추가될 예정입니다.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
