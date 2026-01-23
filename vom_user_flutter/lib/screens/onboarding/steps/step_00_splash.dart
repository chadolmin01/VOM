import 'package:flutter/material.dart';
import '../../../services/tts_service.dart';

/// [V.O.M 온보딩 - Step 0: 스플래시 화면]
/// 로고 애니메이션과 TTS 인사말
class Step00Splash extends StatefulWidget {
  final VoidCallback onNext;

  const Step00Splash({super.key, required this.onNext});

  @override
  State<Step00Splash> createState() => _Step00SplashState();
}

class _Step00SplashState extends State<Step00Splash>
    with SingleTickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _logoFloatController;
  late Animation<Offset> _logoFloatAnimation;

  @override
  void initState() {
    super.initState();

    // 로고 부유 애니메이션 설정 (둥둥 떠 있는 느낌)
    _logoFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoFloatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _logoFloatController,
      curve: Curves.easeInOut,
    ));

    _startSplash();
  }

  Future<void> _startSplash() async {
    // 1. TTS 서비스 초기화 및 인사말 재생
    await _ttsService.init();

    // 어머니들이 인지하기 쉽도록 약간 천천히 말하기 (음성 안내 최적화)
    await _ttsService.speak(
      "어머니, 안녕하세요! 세상에서 가장 따뜻한 학교, 봄에 오신 것을 환영합니다.",
    );

    // 2. 인사가 어느 정도 진행된 후 스플래시 종료 (약 3.5초)
    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      widget.onNext();
    }
  }

  @override
  void dispose() {
    _logoFloatController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _logoFloatAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [Cursor 가이드] 실제 로고 이미지 파일이 있다면 Image.asset으로 교체하세요.
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7E36), // VOM Orange
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wb_sunny_rounded, // 따뜻한 햇살 아이콘
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "봄",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191F28), // 토스 텍스트 블랙
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
