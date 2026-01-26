import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui'; // 블러 효과를 위해 필요
import '../widgets/student_id_card.dart';
import '../../../../data/services/vibration_service.dart';

/// [V.O.M 온보딩 - Step 10: 입학 완료 화면]
/// 특징: 3D 카드 플립, 오로라 배경 효과, 중앙 정렬 레이아웃
class Step10Completion extends StatefulWidget {
  final String name;
  final List<String> interests;
  final VoidCallback onFinish;
  final VoidCallback? onBack;

  const Step10Completion({
    super.key,
    required this.name,
    required this.interests,
    required this.onFinish,
    this.onBack,
  });

  @override
  State<Step10Completion> createState() => _Step10CompletionState();
}

class _Step10CompletionState extends State<Step10Completion> with TickerProviderStateMixin {
  late AnimationController _flipController; // 카드 회전용
  late AnimationController _auroraController; // 오로라 배경용

  @override
  void initState() {
    super.initState();

    // 1. 카드 회전 애니메이션
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _flipController.forward();
    
    // 2. 오로라 배경 애니메이션 (천천히 반복)
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // 아주 천천히 움직임
    )..repeat(reverse: true); // 왔다갔다 반복

    // 3. 성공 진동
    Future.delayed(const Duration(milliseconds: 300), () {
      VibrationService.success();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1), // 기본 배경색
      body: Stack(
        children: [
          // [NEW] 1. 오로라 배경 효과 (가장 뒤)
          _buildAuroraBackground(),

          // 2. 메인 컨텐츠 (중앙 정렬 레이아웃)
          SafeArea(
            child: Column(
              children: [
                // 상단 뒤로가기 버튼
                if (widget.onBack != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF8B95A1)),
                      label: const Text("이전으로", style: TextStyle(fontSize: 16, color: Color(0xFF505967), fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(padding: const EdgeInsets.all(12), backgroundColor: Colors.transparent),
                    ),
                  ),

                // 상단/중앙 영역을 꽉 채워서 내용을 중앙에 배치
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D 회전 학생증 (Hero)
                      GestureDetector(
                        onTap: () {
                          if (_flipController.isCompleted) {
                            _flipController.reverse();
                          } else {
                            _flipController.forward();
                          }
                          VibrationService.tap();
                        },
                        child: AnimatedBuilder(
                          animation: _flipController,
                          builder: (context, child) {
                            final double angle = Curves.easeInOutBack.transform(_flipController.value) * pi;
                            final bool isBack = angle > pi / 2;

                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: isBack
                                  ? Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..rotateY(pi),
                                      child: _buildCardBack(),
                                    )
                                  : _buildCardFront(),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 힌트 텍스트
                      AnimatedOpacity(
                        opacity: 0.6,
                        duration: const Duration(milliseconds: 500),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded, size: 16, color: Color(0xFF8B95A1)),
                            SizedBox(width: 4),
                            Text(
                              "카드를 눌러서 뒷면을 확인해보세요",
                              style: TextStyle(color: Color(0xFF8B95A1), fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48), // 카드와 텍스트 사이 간격 넓힘

                      // 축하 메시지
                      const Text(
                        "입학을 축하합니다!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191F28),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${widget.name}님의 새로운 시작을\n봄이 언제나 응원할게요.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF4E5968),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. 하단 버튼 (바닥에 고정)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: widget.onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7E36),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "나의 교실로 입장하기",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- [NEW] 오로라 배경 위젯 ---
  Widget _buildAuroraBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        // 애니메이션 값에 따라 위치가 미세하게 움직임
        final move = _auroraController.value * 50;
        
        return Stack(
          children: [
            // 1. 따뜻한 오렌지 빛 (왼쪽 상단에서 이동)
            Positioned(
              top: -100 + move,
              left: -100 - move,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF7E36).withOpacity(0.3), // VOM Orange
                ),
                // 엄청난 블러 처리로 빛처럼 보이게 함
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            // 2. 부드러운 노란 빛 (오른쪽 중앙에서 이동)
            Positioned(
              top: MediaQuery.of(context).size.height / 3 - move,
              right: -50 + move,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC107).withOpacity(0.2), // Warm Yellow
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            // 3. 전체적인 화이트 오버레이 (너무 진하지 않게)
            Positioned.fill(
              child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                 child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            )
          ],
        );
      },
    );
  }

  // 앞면: 기존 학생증 위젯 재사용
  Widget _buildCardFront() {
    return StudentIDCard(
      name: widget.name,
      phone: "인증 학생",
      isFinal: true,
    );
  }

  // 뒷면: 선택한 관심사 목록 (커스텀 디자인)
  Widget _buildCardBack() {
    return Container(
      width: double.infinity,
      height: 200, // 앞면과 동일한 높이
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7E36).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFFF7E36), width: 1), // 뒷면은 오렌지 테두리
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "나의 관심사",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B95A1),
                ),
              ),
              // V.O.M 로고 작게
              Icon(Icons.wb_sunny_rounded, color: const Color(0xFFFF7E36).withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          
          // 뱃지 리스트
          if (widget.interests.isEmpty)
             const Center(child: Text("선택된 관심사가 없어요"))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.interests.map((id) {
                // ID를 한글명으로 변환하는 간단한 맵퍼 (실제론 데이터 모델 사용 권장)
                final title = _getInterestTitle(id);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF7E36).withOpacity(0.3)),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFF7E36),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ID -> 한글 변환 헬퍼 (예시)
  String _getInterestTitle(String id) {
    const map = {
      'health': '가족 건강', 'cooking': '요리', 'smartphone': '스마트폰',
      'voice_phishing': '금융 사기', 'kiosk': '키오스크', 'transport': '길 찾기'
    };
    return map[id] ?? id;
  }
}
