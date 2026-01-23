import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../constants/app_colors.dart';
import '../constants/nfc_contents.dart';
import '../router/deep_link_handler.dart';
import '../services/mission_repository.dart';
import '../services/supabase_service.dart';
import '../services/nfc_intent_service.dart';
import '../services/onboarding_backend.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import '../widgets/mission_error_bottom_sheet.dart';
import 'learning_screen.dart';
import 'scan_screen.dart';
import 'onboarding/care_onboarding_screen.dart';

// 온보딩과 동일한 색상 스타일
const Color _kPrimaryOrange = Color(0xFFFF7E36); // 좀 더 생동감 있는 오렌지
const Color _kBackgroundCream = Color(0xFFF8F9FA); // 토스식 밝은 그레이/화이트
const Color _kCardWhite = Colors.white;
const Color _kTextMain = Color(0xFF1A1C1E);
const Color _kTextSub = Color(0xFF8B95A1);

class TagWaitScreen extends StatefulWidget {
  const TagWaitScreen({super.key});

  @override
  State<TagWaitScreen> createState() => _TagWaitScreenState();
}

class _TagWaitScreenState extends State<TagWaitScreen>
    with TickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  final MissionRepository _missionRepository = MissionRepository();
  final SupabaseService _supabaseService = SupabaseService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isNfcAvailable = false;
  bool _isNfcListening = false;
  String? _userName; // 사용자 이름 (온보딩에서 저장된 값)
  int _attendanceCount = 0; // 출석 도장 개수 (임시, 나중에 서버에서 가져올 예정)

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserProfile();
    _checkNfcAvailability();
    _setupBackgroundNfcListener();
  }

  /// 사용자 프로필 불러오기 (이름 등)
  Future<void> _loadUserProfile() async {
    final profile = await onboardingBackend.loadProfile();
    if (profile != null && profile.name != null) {
      setState(() {
        _userName = profile.name;
      });
    }
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

    final matchedContent = await _missionRepository.loadByNfcTagId(tagId);

    if (!mounted) return;

    if (matchedContent != null) {
      await VibrationService.success();
      _goToLearningDirect(matchedContent);
    } else {
      await VibrationService.error();
      await _showNotFoundDialog(tagId);
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

  /// 개발용: Supabase 로그아웃 + 온보딩 처음부터 다시 시작
  Future<void> _devResetOnboarding() async {
    try {
      await _supabaseService.signOut();
      if (!mounted) return;

      // 온보딩 화면부터 다시 시작
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const CareOnboardingScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Dev reset onboarding error: $e');
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
      final matchedContent = await _missionRepository.loadByNfcTagId(tag.id);

      await FlutterNfcKit.finish();

      if (mounted) {
        setState(() => _isNfcListening = false);
        if (matchedContent != null) {
          await VibrationService.success();
          _goToLearningDirect(matchedContent); // 바로 학습 화면으로 전환
        } else {
          await VibrationService.error();
          await _showNotFoundDialog(tag.id);
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

  Future<void> _showNotFoundDialog(String tagId) async {
    await _ttsService.speak('이 카드가 아직 등록되지 않았어요');

    await showMissionNotFoundBottomSheet(
      context,
      title: '등록되지 않은 카드예요',
      message: '관리자에게 카드 등록을 요청해주세요.',
      idLabel: 'UID',
      idValue: tagId,
      helpText: 'NFC 카드를 다시 태그해 주세요.',
    );

    if (mounted && !_isNfcListening) {
      _startNfcPolling();
    }
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

  /// 디지털 학생증 카드 (상단)
  Widget _buildStudentCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _kPrimaryOrange.withOpacity(0.1),
            child: const Icon(Icons.person, color: _kPrimaryOrange, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? "학생",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kTextMain,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "봄 학교 학생",
                  style: TextStyle(
                    color: _kTextSub,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2, color: _kTextSub, size: 32),
        ],
      ),
    );
  }

  /// 오늘의 수업 카드 (넷플릭스 스타일)
  Widget _buildTodayClassCard() {
    return GestureDetector(
      onTap: () {
        if (_isNfcAvailable) {
          _showCardSelectDialog();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()),
          ).then((_) {
            if (mounted) _startNfcPolling();
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _kPrimaryOrange,
              _kPrimaryOrange.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _kPrimaryOrange.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_rounded,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                '오늘의 수업',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isNfcAvailable
                    ? '카드를 태그하거나 터치하세요'
                    : 'QR코드를 스캔하거나 터치하세요',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              if (_isNfcAvailable && _isNfcListening) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.nfc, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'NFC 대기 중...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 출석 도장판 섹션
  Widget _buildAttendanceStamp() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '출석 도장판',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _kTextMain,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isStamped = index < _attendanceCount;
              return GestureDetector(
                onTap: () async {
                  if (!isStamped && index == _attendanceCount) {
                    setState(() {
                      _attendanceCount++;
                    });
                    await VibrationService.success();
                    // 도장 찍는 애니메이션 효과 (간단한 스케일)
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isStamped
                        ? _kPrimaryOrange.withOpacity(0.2)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isStamped ? _kPrimaryOrange : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isStamped
                        ? const Icon(
                            Icons.check_circle,
                            color: _kPrimaryOrange,
                            size: 24,
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '오늘 $_attendanceCount/7 도장',
            style: const TextStyle(
              fontSize: 14,
              color: _kTextSub,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 주황색 큰 버튼 빌더 (온보딩과 동일한 스타일)
  Widget _buildPrimaryButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimaryOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundCream, // 온보딩과 동일한 크림 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (_isNfcAvailable) {
                _ttsService.speak("카드를 태그하거나 QR코드를 스캔해주세요");
              } else {
                _ttsService.speak("QR코드를 스캔하거나 카드를 선택해주세요");
              }
            },
            icon: const Icon(Icons.volume_up_rounded),
            color: Colors.black54,
          ),
          if (kDebugMode)
            IconButton(
              tooltip: '개발용: 온보딩 초기화',
              onPressed: _devResetOnboarding,
              icon: const Icon(Icons.logout_rounded),
              color: Colors.black54,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 상단: 디지털 학생증 카드
              _buildStudentCard(),
              const SizedBox(height: 24),

              // 중간: 오늘의 수업 (넷플릭스 카드 스타일)
              _buildTodayClassCard(),
              const SizedBox(height: 24),

              // 하단: 출석 도장판
              _buildAttendanceStamp(),
              const SizedBox(height: 24),

              // 학습 시작 버튼
              _buildPrimaryButton(
                '학습 시작하기',
                onPressed: () {
                  if (_isNfcAvailable) {
                    _showCardSelectDialog();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScanScreen()),
                    ).then((_) {
                      if (mounted) _startNfcPolling();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
