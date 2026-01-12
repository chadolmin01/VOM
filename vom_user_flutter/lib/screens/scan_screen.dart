import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants/app_colors.dart';
import '../constants/nfc_contents.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import '../services/supabase_service.dart';
import 'learning_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TtsService _tts = TtsService();
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _tts.speak('QR코드를 카메라에 비춰주세요.');
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    // QR 코드로 콘텐츠 찾기 (v2 - UID 매핑 방식)
    CardContent? matchedContent;

    // 1. Supabase에서 QR 코드로 콘텐츠 조회
    try {
      final dbContent = await SupabaseService().getContentByQrCode(code);
      if (dbContent != null) {
        matchedContent = CardContent.fromJson(dbContent);
      }
    } catch (e) {
      debugPrint('Supabase QR lookup failed: $e');
    }

    // 2. DB에 없으면 기존 매핑에서 card_id로 폴백 콘텐츠 찾기
    if (matchedContent == null) {
      try {
        final mapping = await SupabaseService().getCardMappingByQrCode(code);
        if (mapping != null) {
          final cardId = mapping['card_id'] as String?;
          if (cardId != null) {
            matchedContent = getFallbackContentById(cardId);
          }
        }
      } catch (e) {
        debugPrint('Supabase QR mapping lookup failed: $e');
      }
    }

    if (!mounted) return;

    if (matchedContent != null) {
      await VibrationService.success();
      _goToLearningDirect(matchedContent);  // 바로 학습 화면으로 전환
    } else {
      await VibrationService.error();
      _showNotFoundDialog(code);
    }
  }

  void _showNotFoundDialog(String qrCode) {
    _tts.speak('이 QR코드가 아직 등록되지 않았어요');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              '등록되지 않은 QR코드예요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR: ${qrCode.length > 30 ? '${qrCode.substring(0, 30)}...' : qrCode}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '관리자에게 QR코드 등록을 요청하세요',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isProcessing = false);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('다시 스캔하기'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  /// 등록된 QR 감지 시 바로 학습 화면으로 전환 (다이얼로그 없이)
  void _goToLearningDirect(CardContent card) {
    // 짧은 TTS 안내
    _tts.speak('${card.name} 학습 시작!');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LearningScreen(card: card),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showFoundDialog(CardContent card) {
    _tts.speak('${card.name}를 찾았어요!');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '${card.name}를 찾았어요!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '이 물건의 사용법을 배워볼까요?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _isProcessing = false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearningScreen(card: card),
                        ),
                      );
                    },
                    child: const Text('학습하기'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 실제 카메라 스캐너
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 스캔 프레임 오버레이
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? AppColors.success : AppColors.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isProcessing
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.success),
                    )
                  : null,
            ),
          ),

          // 상단 안내
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isProcessing ? '인식 중...' : 'QR코드를 비춰주세요',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 닫기 버튼
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // 플래시 토글 버튼
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _scannerController?.toggleTorch(),
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 24),
              ),
            ),
          ),

          // 하단 안내
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '물건에 붙어있는 QR코드를\n사각형 안에 맞춰주세요',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
