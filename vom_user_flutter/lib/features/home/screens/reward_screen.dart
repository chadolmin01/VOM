import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/supabase_service.dart';

/// Passive Home 화면 (리워드/스티커 현황)
/// Tunnel UX 철학: 리워드(스티커) 현황만 표시하는 수동적 뷰
/// 사용자는 이 화면에서 메뉴를 탐색하지 않고, 오직 NFC 태깅을 통해서만 기능이 실행됨
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRewardData();
  }

  /// 오늘 완료한 학습 수를 가져와서 리워드 계산
  Future<void> _loadRewardData() async {
    try {
      // TODO: Supabase에서 오늘 완료한 학습 수 조회
      // 현재는 더미 데이터 사용
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _completedCount = 5; // 예시: 오늘 5개 완료
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 완료한 학습 수에 따른 스티커 개수 계산 (3개당 1개 스티커)
  int get _stickerCount => _completedCount ~/ 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'V.O.M',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '오늘의 리워드',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 스티커 현황
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 스티커 그리드
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: 9, // 최대 9개 스티커
                              itemBuilder: (context, index) {
                                final hasSticker = index < _stickerCount;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: hasSticker
                                        ? AppColors.primary.withOpacity(0.1)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasSticker
                                          ? AppColors.primary
                                          : AppColors.divider,
                                      width: hasSticker ? 2 : 1,
                                    ),
                                  ),
                                  child: hasSticker
                                      ? const Icon(
                                          Icons.star_rounded,
                                          color: AppColors.primary,
                                          size: 32,
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 완료 현황 텍스트
                          Text(
                            '오늘 ${_completedCount}개의 학습을 완료했어요!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '스티커 ${_stickerCount}개를 받았어요',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 하단 안내 텍스트
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'NFC 카드를 태그하면\n새로운 학습을 시작할 수 있어요',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
