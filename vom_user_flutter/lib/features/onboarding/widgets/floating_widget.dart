import 'package:flutter/material.dart';
import 'dart:math';

/// 둥실둥실 부유 효과 위젯
/// 학생증 카드 등에 적용하여 부드러운 떠다니는 효과를 제공
class FloatingWidget extends StatefulWidget {
  final Widget child;

  const FloatingWidget({
    super.key,
    required this.child,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget> {
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    // 애니메이션 반복을 위해 계속 재시작
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          _animationValue = 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutSine,
      onEnd: () {
        // 애니메이션 반복을 위해 다시 시작
        if (mounted) {
          _startAnimation();
        }
      },
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * sin(value * 2 * pi)), // 둥실둥실 로직
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
