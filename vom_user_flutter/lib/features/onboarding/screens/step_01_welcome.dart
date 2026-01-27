import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/floating_widget.dart';
import '../../../../data/services/vibration_service.dart'; // 진동 서비스

/// [V.O.M 온보딩 - Step 1: 입학 환영 화면]
/// 특징: 3단계 스토리텔링 캐러셀, 3D 뱃지 아이콘, 인터랙티브 인디케이터
class Step01Welcome extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const Step01Welcome({super.key, required this.onNext, this.onBack});

  @override
  State<Step01Welcome> createState() => _Step01WelcomeState();
}

class _Step01WelcomeState extends State<Step01Welcome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 3단계 온보딩 데이터
  final List<Map<String, dynamic>> _slides = [
    {
      "title": "휴대폰을 물건에\n살짝 대보세요",
      "desc": "복잡하게 검색할 필요 없어요.\n스티커에 대기만 하면 공부가 시작돼요.",
      "icon": Icons.nfc_rounded, // 태그 아이콘
      "color": Color(0xFFFF7E36), // 오렌지
    },
    {
      "title": "글자 대신 영상으로\n쉽게 설명해 줄게요",
      "desc": "읽기 힘든 긴 글은 이제 그만.\n친절한 목소리와 영상으로 배워요.",
      "icon": Icons.play_circle_fill_rounded, // 재생 아이콘
      "color": Color(0xFF4CAF50), // 초록 (편안함)
    },
    {
      "title": "어머니의 성장을\n꼼꼼히 기록해요",
      "desc": "얼마나 공부했는지 알려드리고\n멋진 학생증에 도장도 찍어드려요.",
      "icon": Icons.emoji_events_rounded, // 트로피/리포트 아이콘
      "color": Color(0xFFFFC107), // 노랑 (보상)
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    if (_currentIndex < _slides.length - 1) {
      // 다음 슬라이드로 이동
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    } else {
      // 마지막 슬라이드면 다음 단계(Step 2)로 이동
      widget.onNext();
    }
    VibrationService.tap();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 1. 상단 뒤로가기 버튼
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

          const Spacer(flex: 1),

          // 2. 메인 슬라이드 영역 (PageView)
          SizedBox(
            height: 500, // 아이콘 + 텍스트 영역 높이
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                VibrationService.tap(); // 슬라이드 넘길 때마다 톡톡
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return _buildSlideItem(slide);
              },
            ),
          ),

          const Spacer(flex: 1),

          // 3. 페이지 인디케이터 (점 3개)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8, // 활성 상태면 길어짐 (토스 스타일)
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFFF7E36) : const Color(0xFFE5E8EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // 4. 하단 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _onNextTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  // 마지막 페이지면 '시작하기', 아니면 '다음'
                  _currentIndex == _slides.length - 1 ? "학생증 만들러 가기" : "다음",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 개별 슬라이드 위젯
  Widget _buildSlideItem(Map<String, dynamic> slide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. 커다란 3D 뱃지 아이콘
        FloatingWidget( // 둥둥 떠다니는 효과
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              // Claymorphism: 부드러운 입체 그림자
              boxShadow: [
                BoxShadow(
                  color: slide['color'].withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 30,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: (slide['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  slide['icon'],
                  size: 80,
                  color: slide['color'],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 48),

        // 2. 제목 (토스 스타일 볼드체)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            slide['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: Color(0xFF191F28),
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 3. 설명 (부드러운 그레이)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            slide['desc'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF8B95A1),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
