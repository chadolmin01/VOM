import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../core/constants/app_colors.dart';
import '../data/models/mission.dart';
import '../data/services/mission_cache_service.dart';

/// 미션 플레이어 위젯
/// GIF/Short Loop Video 재생 전용
/// 네트워크 실패 시 캐시된 미디어 재생 지원
class MissionPlayer extends StatefulWidget {
  final Mission mission;
  final bool autoPlay;

  const MissionPlayer({
    super.key,
    required this.mission,
    this.autoPlay = false,
  });

  @override
  State<MissionPlayer> createState() => _MissionPlayerState();
}

class _MissionPlayerState extends State<MissionPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.mission.audioUrl != null) {
      _playAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.mission.audioUrl == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _audioPlayer.play(UrlSource(widget.mission.audioUrl!));
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '오디오 재생 실패';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 비디오/GIF 영역
          if (widget.mission.videoUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: _buildVideoPlayer(),
              ),
            )
          else
            // 비디오가 없으면 아이콘 표시
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Text(
                  widget.mission.icon,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),

          // 오디오 재생 컨트롤
          if (widget.mission.audioUrl != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : (_isPlaying ? _stopAudio : _playAudio),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: AppColors.primary,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error ?? '오디오 재생',
                      style: TextStyle(
                        fontSize: 14,
                        color: _error != null
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // TODO: video_player 패키지를 사용하여 실제 비디오 재생 구현
    // 현재는 플레이스홀더만 표시
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.mission.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              '비디오 재생 영역',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.mission.videoUrl != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.mission.videoUrl!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
