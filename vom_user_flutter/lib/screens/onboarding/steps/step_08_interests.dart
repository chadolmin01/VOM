import 'package:flutter/material.dart';
import '../../../services/vibration_service.dart'; // 진동 서비스

/// [V.O.M 온보딩 - Step 8: 관심사 선택 화면]
/// 특징: 순차적 등장, 직관적인 선택 상태, 마이크로 인터랙션
class Step08Interests extends StatefulWidget {
  final Function(List<String>) onComplete;

  const Step08Interests({super.key, required this.onComplete});

  @override
  State<Step08Interests> createState() => _Step08InterestsState();
}

class _Step08InterestsState extends State<Step08Interests> with SingleTickerProviderStateMixin {
  // 선택된 관심사 ID들을 담는 Set (중복 방지)
  final Set<String> _selectedIds = {};

  // 관심사 데이터 (아이콘은 큼지막한 이모지 활용)
  final List<Map<String, String>> _interests = [
    {'id': 'health', 'title': '가족 건강', 'emoji': '💊'},
    {'id': 'cooking', 'title': '맛있는 요리', 'emoji': '🍳'},
    {'id': 'smartphone', 'title': '스마트폰', 'emoji': '📱'},
    {'id': 'voice_phishing', 'title': '금융 사기 예방', 'emoji': '👮'},
    {'id': 'kiosk', 'title': '키오스크 주문', 'emoji': '🍔'},
    {'id': 'transport', 'title': '길 찾기', 'emoji': '🚌'},
  ];

  late AnimationController _entranceController;
  
  @override
  void initState() {
    super.initState();
    // 카드들이 하나씩 튀어나오게 하기 위한 컨트롤러
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // 카드 선택/해제 로직
  void _toggleInterest(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
        VibrationService.tap(); // 📳 선택 시 기분 좋은 진동
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // 1. 헤더 텍스트
            const Text(
              "어떤 공부를\n제일 먼저 해볼까요?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.4,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "관심 있는 것을 모두 골라보세요.",
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF8B95A1),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // 2. 그리드 리스트 (Expanded로 남은 공간 채움)
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(), // 끝에서 튕기는 스크롤
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2열 배치
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // 정사각형에 가깝게
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final item = _interests[index];
                  final isSelected = _selectedIds.contains(item['id']);

                  // 순차적 등장 애니메이션 (Staggered Animation)
                  // 인덱스마다 100ms씩 늦게 시작됨
                  final Animation<double> animation = CurvedAnimation(
                    parent: _entranceController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0), // 시작 시간
                      (index * 0.1 + 0.5).clamp(0.0, 1.0), // 종료 시간
                      curve: Curves.easeOutBack, // 퐁! 하고 튀어나오는 효과
                    ),
                  );

                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: _buildInterestCard(item, isSelected),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // 3. 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _selectedIds.isNotEmpty
                    ? () => widget.onComplete(_selectedIds.toList())
                    : null, // 선택된 게 없으면 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7E36),
                  disabledBackgroundColor: const Color(0xFFF2F4F6),
                  disabledForegroundColor: const Color(0xFFB0B8C1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _selectedIds.isEmpty 
                      ? "관심사를 선택해주세요" 
                      : "${_selectedIds.length}개 선택 완료",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 개별 관심사 카드 위젯
  Widget _buildInterestCard(Map<String, String> item, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleInterest(item['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF8F1) : Colors.white, // 선택 시 아주 연한 오렌지 배경
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7E36) : Colors.transparent, // 선택 시 오렌지 테두리
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? const Color(0xFFFF7E36).withOpacity(0.15) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 내용물 (이모지 + 텍스트)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['emoji']!,
                    style: const TextStyle(fontSize: 48), // 큼지막한 이모지
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? const Color(0xFFFF7E36) // 선택 시 텍스트도 오렌지
                          : const Color(0xFF333D4B),
                    ),
                  ),
                ],
              ),
            ),
            
            // 우측 상단 체크 아이콘 (선택 시에만 쓱 나타남)
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7E36),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
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
