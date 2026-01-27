import 'package:flutter/material.dart';

/// NFC 스캔 대기 화면
class ScanWaitingTab extends StatefulWidget {
  const ScanWaitingTab({super.key});

  @override
  State<ScanWaitingTab> createState() => _ScanWaitingTabState();
}

class _ScanWaitingTabState extends State<ScanWaitingTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 🎨 컬러 팔레트
  static const Color creamColor = Color(0xFFFEF2E2);
  static const Color orangeColor = Color(0xFFFF7E36);
  static const Color chocoColor = Color(0xFF4B3621);

  @override
  void initState() {
    super.initState();
    // 맥동 애니메이션 (1.0 → 1.15 → 1.0, 반복)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: creamColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // 타이틀
            const Text(
              'NFC 스캔 준비',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: chocoColor,
              ),
            ),

            const SizedBox(height: 60),

            // 맥동하는 NFC 아이콘
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: orangeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: orangeColor.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.nfc_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

            // 안내 메시지
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '학습 카드를\n휴대폰 뒷면에 가져다 대세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: chocoColor,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3-step 가이드
            _buildGuideSteps(),

            const Spacer(),

            // 하단 도움말
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: orangeColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'NFC 기능이 켜져 있는지 확인하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: chocoColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildGuideStep(1, '카드를 준비하세요', Icons.credit_card),
          const SizedBox(height: 16),
          _buildGuideStep(2, '휴대폰 뒷면에 대세요', Icons.phone_android),
          const SizedBox(height: 16),
          _buildGuideStep(3, '학습을 시작하세요', Icons.school_rounded),
        ],
      ),
    );
  }

  Widget _buildGuideStep(int step, String text, IconData icon) {
    return Row(
      children: [
        // Step 번호
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: orangeColor, width: 2),
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: orangeColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 아이콘
        Icon(icon, color: chocoColor.withOpacity(0.6), size: 24),
        const SizedBox(width: 12),
        // 텍스트
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: chocoColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
