import 'package:flutter/material.dart';
import '../widgets/student_id_card.dart';
import '../../../services/vibration_service.dart';

/// [V.O.M 온보딩 - Step 7: 인증 성공]
/// 특징: 상단 텍스트 → 중앙 학생증(도장) → 하단 버튼 구조, 일관성 있는 레이아웃
class Step07VerificationSuccess extends StatefulWidget {
  final String userName;
  final VoidCallback onNext;

  const Step07VerificationSuccess({
    super.key,
    required this.userName,
    required this.onNext,
  });

  @override
  State<Step07VerificationSuccess> createState() => _Step07VerificationSuccessState();
}

class _Step07VerificationSuccessState extends State<Step07VerificationSuccess> with SingleTickerProviderStateMixin {
  late AnimationController _stampController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.elasticOut), // 띠용~ 하고 찍히는 느낌
    );

    _fadeAnimation = CurvedAnimation(parent: _stampController, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 300), () {
      _stampController.forward();
      VibrationService.success();
    });
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // --- [상단] 축하 메시지 ---
          const Padding(
            padding: EdgeInsets.only(top: 40.0, bottom: 20),
            child: Text(
              "인증에 성공했어요!",
              style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF191F28),
              ),
            ),
          ),

          // --- [중앙] 학생증 + 도장 (Hero) ---
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 학생증
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: StudentIDCard(
                      name: widget.userName,
                      phone: "010-****-****", // 개인정보 보호 마스킹 느낌
                    ),
                  ),
                  
                  // 도장 (중앙에 쾅!)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.rotate(
                        angle: -0.2, // 살짝 기울여서 찍기 (리얼함)
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF7E36), width: 5),
                            color: Colors.white.withOpacity(0.95),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded, color: Color(0xFFFF7E36), size: 40),
                              Text("인증됨", style: TextStyle(color: Color(0xFFFF7E36), fontWeight: FontWeight.w900, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- [하단] 버튼 ---
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("다음으로", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
