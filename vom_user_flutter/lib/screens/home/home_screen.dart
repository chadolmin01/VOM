import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/scan_waiting_tab.dart';
import 'tabs/mypage_tab.dart';
import '../../widgets/interactive/physical_button.dart';
import '../../widgets/interactive/bounce_icon.dart';

/// V.O.M 홈 화면 - IndexedStack으로 3개 탭 관리
///
/// 구조:
/// - index 0: HomeTab (YouTube 스타일 피드)
/// - index 1: ScanWaitingTab (NFC 스캔 대기)
/// - index 2: MyPageTab (마이페이지)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color orangeColor = Color(0xFFFF7E36);

  // 하단 네비게이션 인덱스
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentNavIndex,
        children: const [
          HomeTab(),          // index: 0
          ScanWaitingTab(),   // index: 1
          MyPageTab(),        // index: 2
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// 하단 네비게이션 바
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 홈 버튼
              _buildNavItem(
                icon: Icons.home_rounded,
                label: '홈',
                index: 0,
              ),
              // 스캔 버튼 (중앙, 강조)
              _buildNavItem(
                icon: Icons.nfc_rounded,
                label: '스캔',
                index: 1,
                isCenter: true,
              ),
              // 마이페이지 버튼
              _buildNavItem(
                icon: Icons.person_rounded,
                label: '마이',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = _currentNavIndex == index;

    if (isCenter) {
      // 중앙 스캔 버튼
      return PhysicalButton(
        scale: 0.85,
        onPressed: () {
          setState(() => _currentNavIndex = index);
          debugPrint('🔍 NFC 스캔 화면 표시');
        },
        enableShadow: false,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: orangeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: orangeColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      );
    }

    // 홈/마이 버튼
    return BounceIcon(
      icon: icon,
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 0) {
          debugPrint('🏠 홈 화면');
        } else if (index == 2) {
          debugPrint('👤 마이페이지');
        }
      },
      color: isSelected ? orangeColor : Colors.grey[400],
      size: 28,
      isSelected: isSelected,
      label: label,
    );
  }
}
