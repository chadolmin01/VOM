import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// 둥근 모서리 카드 UI
/// TODO: VOM 디자인 시스템에 맞는 카드 위젯 구현 예정
class VomCard extends StatelessWidget {
  final Widget child;
  
  const VomCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
