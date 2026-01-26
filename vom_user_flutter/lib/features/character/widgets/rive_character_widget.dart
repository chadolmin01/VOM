import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Rive 캐릭터 표시 위젯
/// TODO: Rive 애니메이션 연동 구현 예정
class RiveCharacterWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const RiveCharacterWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 8),
            Text(
              'Rive 캐릭터',
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
