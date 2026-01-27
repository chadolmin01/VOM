import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../classroom/screens/shortform_feed_tab.dart';
import '../../community/screens/community_tab.dart';
import '../../admin/screens/mypage_tab.dart';
import 'home_tab.dart';

/// 메인 탭 네비게이션 화면
/// 학교 컨셉: 홈(나의 책상), 1교시(행동 교실), 쉬는 시간(커뮤니티), 교무실(마이페이지)
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(), // 홈: 나의 책상
    ShortformFeedTab(), // 1교시: 행동 교실
    CommunityTab(), // 쉬는 시간: 커뮤니티
    MyPageTab(), // 교무실: 마이페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '나의 책상',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: '1교시',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: '쉬는 시간',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: '교무실',
          ),
        ],
      ),
    );
  }
}

