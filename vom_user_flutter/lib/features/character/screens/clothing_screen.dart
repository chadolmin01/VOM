import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 내 옷장 화면
/// TODO: 캐릭터 옷 입히기 기능 구현 예정
class ClothingScreen extends StatelessWidget {
  const ClothingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내 옷장'),
        backgroundColor: AppColors.background,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              '내 옷장',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '캐릭터 옷 입히기 기능이 곧 추가될 예정입니다.',
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
