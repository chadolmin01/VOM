import 'package:flutter/material.dart';
import '../../../widgets/interactive/physical_button.dart';
import '../../../widgets/interactive/liftable_card.dart';
import '../../../services/dev_mode_service.dart';
import '../../debug/debug_screen.dart';
import '../../shorts/shorts_screen.dart';

/// 홈 탭 - YouTube 스타일 피드
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // 🎨 컬러 팔레트
  static const Color creamColor = Color(0xFFFEF2E2);
  static const Color orangeColor = Color(0xFFFF7E36);
  static const Color chocoColor = Color(0xFF4B3621);

  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    '전체',
    '🍼 수유',
    '💩 기저귀',
    '🛁 목욕',
    '🌙 수면',
    '🤒 건강',
  ];

  final List<Map<String, dynamic>> _dummyVideos = [
    {
      'title': '분유 타는 법',
      'duration': '2:15',
      'thumbnail': const Color(0xFFFF6B9D),
      'category': '🍼 수유',
    },
    {
      'title': '기저귀 교체',
      'duration': '1:45',
      'thumbnail': const Color(0xFF4ECDC4),
      'category': '💩 기저귀',
    },
    {
      'title': '목욕 시키기',
      'duration': '3:20',
      'thumbnail': const Color(0xFFFFA07A),
      'category': '🛁 목욕',
    },
    {
      'title': '트림 시키기',
      'duration': '1:30',
      'thumbnail': const Color(0xFF9B59B6),
      'category': '🍼 수유',
    },
    {
      'title': '아기 재우기',
      'duration': '4:10',
      'thumbnail': const Color(0xFF3498DB),
      'category': '🌙 수면',
    },
    {
      'title': '체온 재기',
      'duration': '2:00',
      'thumbnail': const Color(0xFFE74C3C),
      'category': '🤒 건강',
    },
    {
      'title': '수유 자세',
      'duration': '2:45',
      'thumbnail': const Color(0xFF1ABC9C),
      'category': '🍼 수유',
    },
    {
      'title': '목 가누기',
      'duration': '3:00',
      'thumbnail': const Color(0xFFF39C12),
      'category': '🤒 건강',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryChips(),
        Expanded(child: _buildVideoGrid()),
      ],
    );
  }

  /// 상단 헤더 (인사말 + 검색)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      decoration: const BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 인사말
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕하세요,\n지수 엄마! ☀️',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: chocoColor,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '오늘은 무엇을 배워볼까요?',
                      style: TextStyle(
                        fontSize: 16,
                        color: chocoColor,
                      ),
                    ),
                  ],
                ),
              ),
              // 버튼들
              Row(
                children: [
                  // 검색 버튼
                  PhysicalButton(
                    onPressed: () {
                      debugPrint('🔍 검색 버튼 클릭');
                    },
                    enableShadow: false,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: orangeColor,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 디버그 버튼 (Dev Mode일 때만 표시)
                  if (DevModeService().isDevMode)
                    PhysicalButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DebugScreen()),
                        );
                      },
                      enableShadow: false,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bug_report,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 카테고리 칩 (가로 스크롤)
  Widget _buildCategoryChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PhysicalButton(
              onPressed: () {
                setState(() => _selectedCategoryIndex = index);
              },
              enableShadow: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? orangeColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 메인 콘텐츠 (2열 그리드 - YouTube Shorts 스타일)
  Widget _buildVideoGrid() {
    // 선택된 카테고리에 맞는 영상만 필터링
    final filteredVideos = _selectedCategoryIndex == 0
        ? _dummyVideos
        : _dummyVideos
            .where((v) => v['category'] == _categories[_selectedCategoryIndex])
            .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2열
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.6, // 세로로 긴 비율 (Shorts 스타일)
      ),
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return _buildVideoCard(video);
      },
    );
  }

  /// 개별 비디오 카드 (폴라로이드 + YouTube Shorts 썸네일 스타일)
  Widget _buildVideoCard(Map<String, dynamic> video) {
    return LiftableCard(
      onTap: () {
        // Shorts 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ShortsScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 영역
            Expanded(
              child: Stack(
                children: [
                  // 썸네일 이미지 (더미 컬러)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: video['thumbnail'] as Color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // 재생 시간 (우측 하단)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video['duration'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 제목 영역 (폴라로이드 하단부)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: chocoColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: creamColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          video['category'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: chocoColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
