import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/floating_widget.dart';
import '../widgets/student_id_card.dart';

/// [V.O.M 온보딩 - Step 3: 학생증 생성 화면 (빈 카드)]
/// 컨셉: 3D 틸팅 등장, 스포트라이트 효과, Hero 텍스트 연출
class Step03CardIntro extends StatefulWidget {
  final VoidCallback onNext;
  final String userName; // 아직은 비어있을 확률이 높지만 확장성을 위해
  final VoidCallback? onBack;

  const Step03CardIntro({
    super.key,
    required this.onNext,
    this.userName = "",
    this.onBack,
  });

  @override
  State<Step03CardIntro> createState() => _Step03CardIntroState();
}

class _Step03CardIntroState extends State<Step03CardIntro> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _cardScaleAnim;
  late Animation<double> _cardTiltAnim; // 3D 회전 효과
  late Animation<double> _opacityAnim;
  late Animation<Offset> _textSlideAnim;
  late Animation<Offset> _buttonSlideAnim;

  double _buttonScale = 1.0; // 버튼 탭 효과용

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 1. 카드가 작고 기울어진 상태에서 -> 크고 바르게 펴짐
    _cardScaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    // X축 회전 (인사하듯 숙였다가 펴짐)
    _cardTiltAnim = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 2. 전체 투명도 (부드럽게 등장)
    _opacityAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    // 3. 텍스트와 버튼은 카드가 자리를 잡은 뒤 올라옴
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutQuart),
    ));

    _buttonSlideAnim = Tween<Offset>(
      begin: const Offset(0, 1.0), // 화면 밖에서
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onButtonTap() {
    setState(() => _buttonScale = 0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _buttonScale = 1.0);
        widget.onNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // 상단 뒤로가기 버튼
          if (widget.onBack != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
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
            ),

          // [배경 효과] 중앙에서 퍼져나가는 은은한 빛 (Spotlight)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2), // 카드 위치 쯤
                  radius: 0.8,
                  colors: [
                    const Color(0xFFFF7E36).withOpacity(0.05), // 아주 연한 오렌지
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // --- 1. 주인공: 학생증 (3D Tilt + Scale + Floating) ---
                FadeTransition(
                  opacity: _opacityAnim,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 원근감 (Perspective)
                          ..scale(_cardScaleAnim.value) // 커짐
                          ..rotateX(_cardTiltAnim.value * pi), // 인사하듯 회전
                        child: child,
                      );
                    },
                    child: FloatingWidget(
                      // 빈 학생증 (이름 부분은 "......" 등으로 처리됨)
                      child: StudentIDCard(name: widget.userName),
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // --- 2. 설명 텍스트 (Slide Up) ---
                SlideTransition(
                  position: _textSlideAnim,
                  child: FadeTransition(
                    opacity: _opacityAnim,
                    child: Column(
                      children: const [
                        Text(
                          "어머니만의\n학생증을 만들 거예요",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            color: Color(0xFF191F28),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "가장 먼저 이름부터 채워볼까요?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF8B95A1),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // --- 3. 하단 버튼 (Bouncy) ---
                SlideTransition(
                  position: _buttonSlideAnim,
                  child: AnimatedScale(
                    scale: _buttonScale,
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _onButtonTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E36),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "이름 입력하기",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
