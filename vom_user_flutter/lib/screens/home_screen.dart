import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/nfc_contents.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import 'learning_screen.dart';
import 'scan_screen.dart';
import 'voice_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TtsService _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _playGreeting();
  }

  Future<void> _playGreeting() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _tts.speak('안녕하세요! 학습할 카드를 선택해주세요.');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'V.O.M',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '오늘은 무엇을\n배워볼까요?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // 카드 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: nfcContents.length,
                itemBuilder: (context, index) {
                  final card = nfcContents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      onTap: () {
                        VibrationService.tap();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LearningScreen(card: card),
                          ),
                        );
                      },
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            card.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      title: Text(
                        card.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${card.script.length}단계 학습',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI 도우미 버튼
          FloatingActionButton(
            heroTag: 'ai_helper',
            onPressed: () {
              VibrationService.tap();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceChatScreen(),
                ),
              );
            },
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // QR 스캔 버튼
          FloatingActionButton.extended(
            heroTag: 'qr_scan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            label: const Text(
              '스캔하기',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
        ],
      ),
    );
  }
}