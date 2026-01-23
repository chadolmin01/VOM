import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../domain/shortform.dart';
import '../services/supabase_service.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';

/// 숏폼(마이크로 러닝) 플레이어 화면
/// - 세로 풀스크린 영상 영역 (현재는 플레이스홀더)
/// - 하단: 따라했어요(데모), SOS 버튼
/// - 미션 완료 시: 폭죽/칭찬 오버레이 + 3초 후 이전 화면으로 복귀
class ShortformPlayerScreen extends StatefulWidget {
  final Shortform shortform;

  const ShortformPlayerScreen({
    super.key,
    required this.shortform,
  });

  @override
  State<ShortformPlayerScreen> createState() => _ShortformPlayerScreenState();
}

class _ShortformPlayerScreenState extends State<ShortformPlayerScreen> {
  final SupabaseService _supabase = SupabaseService();
  final TtsService _tts = TtsService();

  bool _isCompleted = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _speakIntro();
  }

  Future<void> _speakIntro() async {
    await _tts.speak('${widget.shortform.title}를 같이 해볼까요?');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildVideoArea(),
            _buildTopOverlay(),
            _buildBottomOverlay(),
            if (_isCompleted) _buildCompletionOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.smart_display_rounded,
                color: Colors.white70,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                '숏폼 비디오 영역 (데모)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.shortform.videoUrl,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.shortform.category,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.shortform.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.95),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onPressed: _isProcessing ? null : _onFollowTap,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    '따라했어요 (데모)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.85),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _onSosTap,
                icon: const Icon(Icons.sos_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onFollowTap() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // TODO: 추후 실제 녹음/행동 인증 로직 추가

      // 데모용: 간단한 학습 로그만 전송
      await _supabase.sendLearningLog(
        cardName: widget.shortform.title,
        cardIcon: '🎬',
        cardId: widget.shortform.id,
      );

      await VibrationService.celebrate();
      await _tts.speak('참 잘했어요! 칭찬 도장을 하나 찍어드릴게요.');

      if (!mounted) return;
      setState(() {
        _isCompleted = true;
      });

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onSosTap() async {
    await VibrationService.error();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('도움이 필요하신가요?'),
        content: const Text(
          '이 버튼은 나중에 선생님/센터로 바로 연결되는 기능이에요.\n\n'
          '데모 버전에서는 실제로 연결되지는 않습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.emoji_events_rounded,
                color: AppColors.primary,
                size: 72,
              ),
              SizedBox(height: 16),
              Text(
                '참 잘했어요!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '칭찬 도장을 하나 찍어드렸어요.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

