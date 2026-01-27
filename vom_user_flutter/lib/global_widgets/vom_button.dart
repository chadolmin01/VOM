import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// VOM 스타일 버튼
/// TODO: VOM 디자인 시스템에 맞는 버튼 위젯 구현 예정
class VomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const VomButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
