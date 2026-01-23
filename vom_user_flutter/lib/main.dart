import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_colors.dart';
import 'router/deep_link_handler.dart';
import 'screens/onboarding/care_onboarding_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/learning_screen.dart';
import 'services/app_entry_service.dart';
import 'services/tts_service.dart';
import 'services/vibration_service.dart';
import 'services/supabase_service.dart';
import 'services/mission_repository.dart';
import 'services/nfc_intent_service.dart';
import 'services/onboarding_backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 투명 + 아이콘 검정 (깔끔한 룩)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await TtsService().init();
  await VibrationService.init();
  await SupabaseService().init();

  runApp(const VomApp());
}

class VomApp extends StatefulWidget {
  const VomApp({super.key});

  @override
  State<VomApp> createState() => _VomAppState();
}

class _VomAppState extends State<VomApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // 앱 시작 시 initial link 처리
    DeepLinkHandler.instance.handleInitialLink(_appLinks);

    // 실행 중 들어오는 링크 스트림 처리
    _appLinks.uriLinkStream.listen(
      (uri) {
        DeepLinkHandler.instance.handleUri(uri);
      },
      onError: (err) {
        debugPrint('❌ AppLinks stream error: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V.O.M',
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard', // 프리텐다드 폰트 적용 (없으면 기본 시스템 폰트)
        scaffoldBackgroundColor: AppColors.background, // 배경색 변경
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.white,
        ),

        // 앱바 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
        ),

        // 버튼 테마 (토스 스타일: 꽉 찬 파란색, 둥근 모서리)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0, // 그림자 제거 (플랫 디자인)
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
      // 진입 경로에 따라 초기 화면 결정:
      // - 입구 (NFC 태그): AppEntryScreen에서 처리 → 바로 학습 화면
      // - 사이드 입구 (직접 실행): AppEntryScreen에서 온보딩 체크 → 홈 화면
      home: const DebugHomeWrapper(child: AppEntryScreen()),
    );
  }
}

/// 앱 진입 경로를 판단하고 적절한 화면으로 라우팅하는 초기 화면
class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkEntryRoute();
  }

  /// 진입 경로 확인 및 라우팅
  Future<void> _checkEntryRoute() async {
    // 1. 입구 (NFC 태그로 열렸는지 확인)
    final nfcTagId = await AppEntryService.checkInitialNfcIntent();

    if (nfcTagId != null) {
      // NFC 태그로 열렸음 → 바로 학습 화면으로
      debugPrint('🏷️ [AppEntryScreen] NFC entry detected: $nfcTagId');
      if (!mounted) return;

      final missionRepo = MissionRepository();
      final card = await missionRepo.loadByNfcTagId(nfcTagId);

      if (card != null && mounted) {
        await VibrationService.success();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LearningScreen(card: card),
          ),
        );
        return;
      } else {
        // 태그는 감지됐지만 등록되지 않은 카드
        debugPrint('⚠️ [AppEntryScreen] NFC tag not registered: $nfcTagId');
        // 일반 홈 화면으로 이동 (TagWaitScreen에서 에러 처리)
      }
    }

    // 2. 사이드 입구 (일반 실행) → 온보딩 체크 후 홈 화면
    if (!mounted) return;

    // 온보딩 완료 여부 확인
    final profile = await onboardingBackend.loadProfile();
    final onboardingStep = profile?.step;

    if (onboardingStep == 'completed') {
      // 온보딩 완료 → 메인 탭 화면
      debugPrint('✅ [AppEntryScreen] Onboarding completed → MainTabScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
      );
    } else {
      // 온보딩 미완료 → 온보딩 화면으로 이동
      debugPrint('📝 [AppEntryScreen] Onboarding not completed → 온보딩 화면으로 이동');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CareOnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator()
            : const SizedBox(), // 체크 완료되면 자동으로 네비게이션됨
      ),
    );
  }
}

/// 개발용: 어디서나 눌러서 Supabase 로그아웃 + 온보딩 처음부터 다시 시작
class DebugHomeWrapper extends StatefulWidget {
  final Widget child;

  const DebugHomeWrapper({super.key, required this.child});

  @override
  State<DebugHomeWrapper> createState() => _DebugHomeWrapperState();
}

class _DebugHomeWrapperState extends State<DebugHomeWrapper> {
  bool _isResetting = false;

  Future<void> _resetAndGoOnboarding() async {
    if (_isResetting) return;
    setState(() {
      _isResetting = true;
    });

    try {
      // Supabase 세션 로그아웃
      await SupabaseService().signOut();

      // 첫 실행 플래그도 초기화 (필요 시)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstRun', true);

      if (!mounted) return;

      // 온보딩 화면부터 다시 시작
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const CareOnboardingScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('❌ Debug reset error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'debugResetFab',
            backgroundColor: Colors.redAccent,
            onPressed: _isResetting ? null : _resetAndGoOnboarding,
            child: _isResetting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }
}