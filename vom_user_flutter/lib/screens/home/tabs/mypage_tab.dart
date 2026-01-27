import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/interactive/liftable_card.dart';
import '../../../widgets/interactive/physical_button.dart';
import '../../../widgets/interactive/scale_tap.dart';
import '../../../services/supabase_service.dart';
import '../../../services/dev_mode_service.dart';
import '../../../providers/user_provider.dart';
import '../../../models/learning_log_model.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../debug/debug_screen.dart';

/// 마이페이지 탭 - 프로필, 학습 통계, 학습 기록, 설정
class MyPageTab extends ConsumerStatefulWidget {
  const MyPageTab({super.key});

  @override
  ConsumerState<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends ConsumerState<MyPageTab> {
  // 🎨 컬러 팔레트
  static const Color creamColor = Color(0xFFFEF2E2);
  static const Color orangeColor = Color(0xFFFF7E36);
  static const Color chocoColor = Color(0xFF4B3621);

  List<LearningLogModel> _recentLogs = [];
  bool _isLoadingLogs = false;

  @override
  void initState() {
    super.initState();
    _loadRecentLogs();
  }

  Future<void> _loadRecentLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final logs = await SupabaseService().getLearningLogs(limit: 10);
      setState(() {
        _recentLogs = logs;
        _isLoadingLogs = false;
      });
    } catch (e) {
      debugPrint('학습 기록 로드 실패: $e');
      setState(() => _isLoadingLogs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);

    return Container(
      color: creamColor,
      child: SafeArea(
        child: userAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('오류: $error')),
          data: (user) {
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('로그인이 필요합니다'),
                    const SizedBox(height: 20),
                    PhysicalButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: orangeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '로그인하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 프로필 카드
                  _buildProfileCard(user),
                  const SizedBox(height: 24),

                  // 2. 학습 통계
                  _buildLearningStats(),
                  const SizedBox(height: 24),

                  // 3. 최근 학습 기록
                  _buildRecentLearningSection(),
                  const SizedBox(height: 24),

                  // 4. 설정 메뉴
                  _buildSettingsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 1. 프로필 카드
  Widget _buildProfileCard(user) {
    return LiftableCard(
      onTap: () {
        debugPrint('프로필 편집');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 프로필 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: orangeColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: orangeColor, width: 3),
              ),
              child: Center(
                child: Text(
                  user.name?.substring(0, 1) ?? '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: orangeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // 프로필 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? '이름 없음',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: chocoColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user.phone != null)
                    Text(
                      user.phone!,
                      style: TextStyle(
                        fontSize: 14,
                        color: chocoColor.withOpacity(0.6),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: creamColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.userType ?? '일반',
                      style: TextStyle(
                        fontSize: 12,
                        color: chocoColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 편집 아이콘
            Icon(
              Icons.edit_rounded,
              color: chocoColor.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 2. 학습 통계 (오늘/이번 주)
  Widget _buildLearningStats() {
    // 오늘 배운 카드 수 계산
    final today = DateTime.now();
    final todayLogs = _recentLogs.where((log) {
      return log.completedAt.year == today.year &&
          log.completedAt.month == today.month &&
          log.completedAt.day == today.day;
    }).length;

    // 이번 주 배운 카드 수 계산
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekLogs = _recentLogs.where((log) {
      return log.completedAt.isAfter(weekStart);
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.today_rounded,
            label: '오늘',
            value: '$todayLogs',
            unit: '개',
            color: orangeColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_month_rounded,
            label: '이번 주',
            value: '$weekLogs',
            unit: '개',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: chocoColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    color: chocoColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. 최근 학습 기록
  Widget _buildRecentLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 학습 기록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: chocoColor,
              ),
            ),
            if (_recentLogs.isNotEmpty)
              ScaleTap(
                onTap: () {
                  debugPrint('전체 보기');
                },
                child: Text(
                  '전체 보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: orangeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingLogs)
          const Center(child: CircularProgressIndicator())
        else if (_recentLogs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 60,
                  color: chocoColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '아직 학습 기록이 없어요',
                  style: TextStyle(
                    fontSize: 16,
                    color: chocoColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        else
          ..._recentLogs.take(5).map((log) => _buildLearningLogCard(log)),
      ],
    );
  }

  Widget _buildLearningLogCard(LearningLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 카드 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                log.cardIcon ?? '📚',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 카드 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.cardName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: chocoColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(log.completedAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: chocoColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // 퀴즈 결과 (있으면)
          if (log.quizCorrect != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: log.quizCorrect!
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                log.quizCorrect! ? '정답' : '오답',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: log.quizCorrect! ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';

    return '${dt.month}/${dt.day}';
  }

  /// 4. 설정 메뉴
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: chocoColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          label: '알림 설정',
          onTap: () => debugPrint('알림 설정'),
        ),
        _buildSettingItem(
          icon: Icons.language_rounded,
          label: '언어 설정',
          onTap: () => debugPrint('언어 설정'),
        ),
        _buildSettingItem(
          icon: Icons.help_outline_rounded,
          label: '도움말',
          onTap: () => debugPrint('도움말'),
        ),
        if (DevModeService().isDevMode)
          _buildSettingItem(
            icon: Icons.bug_report,
            label: '개발자 도구',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugScreen()),
              );
            },
          ),
        const SizedBox(height: 8),
        _buildSettingItem(
          icon: Icons.logout_rounded,
          label: '로그아웃',
          color: Colors.red,
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && mounted) {
              await SupabaseService().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? chocoColor;

    return ScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: itemColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: itemColor.withOpacity(0.4),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
