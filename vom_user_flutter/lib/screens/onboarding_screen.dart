import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import 'tag_wait_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TtsService _tts = TtsService();
  bool _micPermission = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _playWelcome();
    _checkPermissions();
  }

  Future<void> _playWelcome() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _tts.speak('안녕하세요! 마이크 권한을 허용해주세요.');
  }

  Future<void> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    setState(() {
      _micPermission = micStatus.isGranted;
    });
  }

  Future<void> _requestMicPermission() async {
    setState(() => _isLoading = true);
    final status = await Permission.microphone.request();
    setState(() {
      _micPermission = status.isGranted;
      _isLoading = false;
    });
    if (status.isGranted) {
      await VibrationService.success();
      await _tts.speak('좋아요! 이제 시작할 수 있어요.');
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    _goToMain();
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TagWaitScreen()),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 건너뛰기
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 타이틀 (Big & Bold)
              const Text(
                '반가워요 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'V.O.M이 엄마의 목소리를\n잘 들을 수 있게 해주세요.',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // 권한 상태 카드 (토스 스타일 카드)
              Container(
                width: double.infinity,
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _micPermission ? AppColors.primary100 : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _micPermission ? Icons.mic_rounded : Icons.mic_off_rounded,
                        size: 32,
                        color: _micPermission ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _micPermission ? '준비가 완료되었어요' : '마이크 권한이 필요해요',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _micPermission
                          ? '아래 버튼을 눌러 시작하세요'
                          : '따라 말하기 기능을 사용하려면\n권한 허용이 필요합니다',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 하단 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_micPermission ? _completeOnboarding : _requestMicPermission),
                  // AppTheme에서 설정한 스타일이 자동 적용됨
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(_micPermission ? '시작하기' : '권한 허용하기'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}