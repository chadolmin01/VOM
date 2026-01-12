import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../constants/app_colors.dart';
import '../constants/nfc_contents.dart';
import '../services/nfc_intent_service.dart';
import '../services/supabase_service.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import 'learning_screen.dart';
import 'scan_screen.dart';

class TagWaitScreen extends StatefulWidget {
  const TagWaitScreen({super.key});

  @override
  State<TagWaitScreen> createState() => _TagWaitScreenState();
}

class _TagWaitScreenState extends State<TagWaitScreen>
    with TickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isNfcAvailable = false;
  bool _isNfcListening = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkNfcAvailability();
    _setupBackgroundNfcListener();
  }

  /// Android 백그라운드 NFC 리스너 설정
  void _setupBackgroundNfcListener() {
    NfcIntentService.setOnTagDiscovered((tagId) {
      debugPrint('📱 Background NFC tag received: $tagId');
      _handleBackgroundNfcTag(tagId);
    });
  }

  /// 백그라운드에서 감지된 NFC 태그 처리
  Future<void> _handleBackgroundNfcTag(String tagId) async {
    if (!mounted) return;

    CardContent? matchedContent;

    // 1. Supabase에서 UID로 콘텐츠 조회
    try {
      final dbContent = await SupabaseService().getContentByNfcTagId(tagId);
      if (dbContent != null) {
        matchedContent = CardContent.fromJson(dbContent);
      }
    } catch (e) {
      debugPrint('Background NFC lookup failed: $e');
    }

    // 2. 폴백 콘텐츠 찾기
    if (matchedContent == null) {
      try {
        final mapping = await SupabaseService().getCardMappingByNfcTagId(tagId);
        if (mapping != null) {
          final cardId = mapping['card_id'] as String?;
          if (cardId != null) {
            matchedContent = getFallbackContentById(cardId);
          }
        }
      } catch (e) {
        debugPrint('Background NFC mapping lookup failed: $e');
      }
    }

    if (!mounted) return;

    if (matchedContent != null) {
      await VibrationService.success();
      _goToLearningDirect(matchedContent);
    } else {
      await VibrationService.error();
      _showNotFoundDialog(tagId);
    }
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkNfcAvailability() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      _isNfcAvailable = availability == NFCAvailability.available;
      setState(() {});

      await Future.delayed(const Duration(milliseconds: 500));
      if (_isNfcAvailable) {
        await _ttsService.speak("NFC 카드를 태그하거나 QR코드를 스캔해주세요");
        _startNfcPolling();
      } else {
        await _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
      }
    } catch (e) {
      debugPrint('NFC 확인 오류: $e');
      await _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
    }
  }

  Future<void> _startNfcPolling() async {
    if (!_isNfcAvailable || _isNfcListening) return;

    setState(() => _isNfcListening = true);

    try {
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
        iosMultipleTagMessage: "여러 카드가 감지되었습니다",
        iosAlertMessage: "NFC 카드를 가까이 대주세요",
      );

      await _handleNfcTag(tag);
    } catch (e) {
      debugPrint('NFC 폴링 오류: $e');
      if (mounted) {
        setState(() => _isNfcListening = false);
        if (e.toString().contains('timeout')) {
          _startNfcPolling();
        }
      }
    }
  }

  Future<void> _handleNfcTag(NFCTag tag) async {
    try {
      CardContent? matchedContent;

      // 1. Supabase에서 UID로 콘텐츠 조회 (v2 방식)
      final dbContent = await SupabaseService().getContentByNfcTagId(tag.id);
      if (dbContent != null) {
        matchedContent = CardContent.fromJson(dbContent);
      }

      // 2. DB에 없으면 기존 매핑에서 card_id로 폴백 콘텐츠 찾기
      if (matchedContent == null) {
        final mapping = await SupabaseService().getCardMappingByNfcTagId(tag.id);
        if (mapping != null) {
          final cardId = mapping['card_id'] as String?;
          if (cardId != null) {
            matchedContent = getFallbackContentById(cardId);
          }
        }
      }

      await FlutterNfcKit.finish();

      if (mounted) {
        setState(() => _isNfcListening = false);
        if (matchedContent != null) {
          await VibrationService.success();
          _goToLearningDirect(matchedContent);  // 바로 학습 화면으로 전환
        } else {
          await VibrationService.error();
          _showNotFoundDialog(tag.id);
        }
      }
    } catch (e) {
      debugPrint('NFC 태그 처리 오류: $e');
      await FlutterNfcKit.finish();
      await VibrationService.error();
      if (mounted) {
        setState(() => _isNfcListening = false);
        _startNfcPolling();
      }
    }
  }

  void _showNotFoundDialog(String tagId) {
    _ttsService.speak('이 카드가 아직 등록되지 않았어요');

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
              '등록되지 않은 카드예요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'UID: $tagId',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '관리자에게 카드 등록을 요청하세요',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startNfcPolling();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('다시 태그하기'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted && !_isNfcListening) {
        _startNfcPolling();
      }
    });
  }

  void _showFoundDialog(CardContent card) {
    _ttsService.speak('${card.name}를 찾았어요!');

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
                      _startNfcPolling();
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
                      _startLearning(card);
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
      if (mounted && !_isNfcListening) {
        _startNfcPolling();
      }
    });
  }

  // 바텀시트로 카드 선택 (폴백 콘텐츠 사용)
  void _showCardSelectDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '학습할 카드를 선택해주세요',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_isNfcAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.nfc, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'NFC 지원',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ...fallbackContents.map((card) => _buildCardItem(card)),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) _startNfcPolling();
    });
  }

  Widget _buildCardItem(CardContent card) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _startLearning(card);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(card.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${card.scripts.length}단계 학습',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// 등록된 NFC/QR 감지 시 바로 학습 화면으로 전환 (다이얼로그 없이)
  void _goToLearningDirect(CardContent card) {
    // 짧은 TTS 안내
    _ttsService.speak('${card.name} 학습 시작!');

    if (mounted) {
      Navigator.push(
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
      ).then((_) {
        if (mounted) {
          if (_isNfcAvailable) {
            _ttsService.speak("NFC 카드를 태그하거나 QR코드를 스캔해주세요");
          } else {
            _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
          }
          _startNfcPolling();
        }
      });
    }
  }

  void _startLearning(CardContent card) async {
    await VibrationService.success();
    await _ttsService.speak("${card.name} 학습을 시작합니다");

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearningScreen(card: card),
        ),
      ).then((_) {
        if (mounted) {
          if (_isNfcAvailable) {
            _ttsService.speak("NFC 카드를 태그하거나 QR코드를 스캔해주세요");
          } else {
            _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
          }
          _startNfcPolling();
        }
      });
    }
  }

  @override
  void dispose() {
    FlutterNfcKit.finish().catchError((_) {});
    NfcIntentService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'V.O.M',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_isNfcAvailable && _isNfcListening) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'NFC',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (_isNfcAvailable) {
                        _ttsService.speak("NFC 카드를 태그하거나 QR코드를 스캔해주세요");
                      } else {
                        _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
                      }
                    },
                    icon: const Icon(Icons.volume_up_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 메인 텍스트
            const Text(
              '어떤 도움이\n필요하신가요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isNfcAvailable
                  ? 'NFC 카드를 태그하면 바로 알려드릴게요'
                  : 'QR코드를 스캔하거나 카드를 선택하세요',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const Spacer(),

            // 메인 액션 버튼 (NFC & QR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // NFC 태그 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCardSelectDialog,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isNfcAvailable ? Icons.nfc_rounded : Icons.touch_app_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isNfcAvailable ? 'NFC 태그' : '카드 선택',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isNfcAvailable && _isNfcListening)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '대기 중...',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // QR 스캔 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ScanScreen()),
                        ).then((_) {
                          if (mounted) _startNfcPolling();
                        });
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 32,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'QR 스캔',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
