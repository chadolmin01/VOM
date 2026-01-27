import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

/// [V.O.M 온보딩 - Step 9: 학생증 발급 중 화면]
/// 역할: Step 8(관심사 선택)과 Step 10(완료) 사이의 브릿지 단계
/// "나만을 위한 맞춤형 결과가 만들어지고 있다"는 기대감을 줍니다.
class Step09Processing extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const Step09Processing({super.key, required this.onNext, this.onBack});

  @override
  State<Step09Processing> createState() => _Step09ProcessingState();
}

class _Step09ProcessingState extends State<Step09Processing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 빙글빙글 도는 애니메이션

    // 2.5초 뒤에 자동으로 다음 단계(Step 10)로 이동
    Timer(const Duration(milliseconds: 2500), () {
      widget.onNext();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. 학생증 아이콘이 빙글빙글 돌면서 생성되는 연출
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Y축 회전 (동전 뒤집듯이)
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_controller.value * 2 * pi),
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 140, // 세로형 카드 비율
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF7E36), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7E36).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fingerprint_rounded, // 지문/인증 아이콘
                      size: 60,
                      color: Color(0xFFFF7E36),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 48),

          // 2. 감성 문구
          const Text(
            "선택하신 내용으로\n학생증을 발급하고 있어요",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: Color(0xFF191F28),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "잠시만 기다려 주세요...",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8B95A1),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
