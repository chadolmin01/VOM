import 'package:flutter/material.dart';
import '../widgets/floating_widget.dart';
import '../../../../data/services/vibration_service.dart';

class Step07BChildInfo extends StatefulWidget {
  final Function(String) onNext;
  final VoidCallback onBack;

  const Step07BChildInfo({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step07BChildInfo> createState() => _Step07BChildInfoState();
}

class _Step07BChildInfoState extends State<Step07BChildInfo> {
  // 5세 미만 타겟 맞춤형 데이터
  final List<Map<String, dynamic>> _ageGroups = [
    {"label": "0~1세", "desc": "누워있거나 기어다녀요", "icon": "🍼"}, // 영아
    {"label": "2세", "desc": "아장아장 걷기 시작해요", "icon": "👟"}, // 걸음마
    {"label": "3세", "desc": "말문이 트이기 시작해요", "icon": "💬"}, // 언어 발달
    {"label": "4세", "desc": "혼자서도 잘 놀아요", "icon": "🧸"}, // 놀이/자아
    {"label": "5세", "desc": "어린이집/유치원에 가요", "icon": "🎒"}, // 사회성
  ];

  int? _selectedIndex;
  double _buttonScale = 1.0;

  void _onConfirmTap() {
    if (_selectedIndex == null) return;
    
    setState(() => _buttonScale = 0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _buttonScale = 1.0);
      // 선택한 나이 정보("2세")를 다음 단계로 넘김
      widget.onNext(_ageGroups[_selectedIndex!]['label']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (!didPop) widget.onBack(); },
      child: SafeArea(
        child: Column(
          children: [
            // 1. 상단 네비게이션
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

            // 2. 질문 (부드러운 구어체)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "우리 아이는 지금\n몇 살인가요?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, height: 1.3, color: Color(0xFF191F28),
                ),
              ),
            ),

            // 3. 나이 선택 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _ageGroups.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _ageGroups[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      VibrationService.tap();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF8F1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF7E36) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? const Color(0xFFFF7E36).withOpacity(0.1) 
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 아이콘 (이모지 활용)
                          Container(
                            width: 48, height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF7E36).withOpacity(0.1) : const Color(0xFFF2F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Text(item['icon'], style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 16),
                          
                          // 텍스트 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['label'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFFFF7E36) : const Color(0xFF191F28),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? const Color(0xFFFF7E36).withOpacity(0.8) : const Color(0xFF8B95A1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 체크 아이콘
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFFFF7E36), size: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: AnimatedScale(
                scale: _buttonScale,
                duration: const Duration(milliseconds: 100),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _selectedIndex != null ? _onConfirmTap : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7E36),
                      disabledBackgroundColor: const Color(0xFFF2F4F6),
                      disabledForegroundColor: const Color(0xFFB0B8C1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "다음으로",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
