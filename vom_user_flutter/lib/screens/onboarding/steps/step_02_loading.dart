import 'package:flutter/material.dart';
import 'dart:async';

/// [V.O.M 온보딩 - Step 2: 로딩 화면]
/// 컨셉: 스토리텔링 로딩, 펄스 애니메이션, 부드러운 진행 바
class Step02Loading extends StatefulWidget {
  final VoidCallback onLoadingComplete;

  const Step02Loading({super.key, required this.onLoadingComplete});

  @override
  State<Step02Loading> createState() => _Step02LoadingState();
}

class _Step02LoadingState extends State<Step02Loading> with TickerProviderStateMixin {
  double _progress = 0.0;
  int _textIndex = 0;
  Timer? _timer;

  // 로딩 멘트 리스트 (스토리텔링)
  final List<String> _loadingMessages = [
    "어머니를 위한\n책상을 닦고 있어요 🧹",
    "교실 창가에\n따스한 햇살을 채우는 중... ☀️",
    "거의 다 되었어요!\n이제 곧 만나요 👋",
  ];

  // 애니메이션 컨트롤러 (펄스 효과용)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. 심장박동처럼 두근거리는(Pulse) 애니메이션 설정
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 무한 반복

    // 퍼져나가는 파동 효과 (0 -> 1)
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );

    _startLoadingSimulation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // 로딩 시뮬레이션 로직
  void _startLoadingSimulation() {
    const totalDuration = 3000; // 총 3초 로딩
    const updateInterval = 50; // 0.05초마다 업데이트
    int ticks = 0;
    final maxTicks = totalDuration / updateInterval;

    _timer = Timer.periodic(const Duration(milliseconds: updateInterval), (timer) {
      ticks++;
      final newProgress = ticks / maxTicks;

      // 진행률에 따라 멘트 변경 (33%, 66% 지점)
      if (newProgress > 0.33 && _textIndex == 0) {
        setState(() => _textIndex = 1);
      } else if (newProgress > 0.66 && _textIndex == 1) {
        setState(() => _textIndex = 2);
      }

      if (newProgress >= 1.0) {
        timer.cancel();
        setState(() => _progress = 1.0);
        // 완료 후 0.5초 뒤 이동 (여운 남기기)
        Future.delayed(const Duration(milliseconds: 500), widget.onLoadingComplete);
      } else {
        setState(() {
          _progress = newProgress;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. 펄스 애니메이션 아이콘 (중앙 시선 집중) ---
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 뒤로 퍼져나가는 파동 (Ripple Effect)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 100 + (_pulseAnimation.value * 60), // 점점 커짐
                        height: 100 + (_pulseAnimation.value * 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF7E36)
                                .withOpacity(1.0 - _pulseAnimation.value), // 점점 투명해짐
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  // 중앙 고정 원
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7E36).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded, // 반짝이는 아이콘
                      size: 48,
                      color: Color(0xFFFF7E36),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // --- 2. 텍스트 교체 애니메이션 (AnimatedSwitcher) ---
            // 텍스트가 바뀔 때 뚝 끊기지 않고 부드럽게 페이드됨
            SizedBox(
              height: 80, // 텍스트 높이 고정 (화면 울렁거림 방지)
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.2), // 아래에서
                        end: Offset.zero, // 위로
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _loadingMessages[_textIndex],
                  key: ValueKey<int>(_textIndex), // Key가 바뀌면 애니메이션 실행
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Color(0xFF191F28),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              "잠시만 기다려 주세요",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF8B95A1),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 60),

            // --- 3. 커스텀 프로그레스 바 ---
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6), // 회색 배경
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // 차오르는 주황색 바
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300), // 부드러운 이동
                        width: constraints.maxWidth * _progress,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7E36),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                             BoxShadow(
                              color: const Color(0xFFFF7E36).withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
