import 'package:flutter/material.dart';
import '../../services/tts_service.dart'; // 기존 서비스 import
import '../../services/onboarding_backend.dart';
import '../tag_wait_screen.dart';

// 각 단계 파일들 import
import 'steps/step_00_splash.dart';
import 'steps/step_01_welcome.dart';
import 'steps/step_02_loading.dart';
import 'steps/step_03_card_intro.dart';
import 'steps/step_04_name_input.dart';
import 'steps/step_05_phone_check.dart';
import 'steps/step_06_otp_input.dart';
import 'steps/step_07_verification_success.dart';
import 'steps/step_08_interests.dart';
import 'steps/step_09_processing.dart';
import 'steps/step_10_completion.dart';

/// [V.O.M 온보딩 시나리오 - 메인 컨트롤러]
/// 🎨 디자인 스타일: 토스(Toss) 스타일 - 여백의 미, 굵은 타이포그래피, 부드러운 애니메이션
/// 🌸 브랜드 컬러: VOM Beige (#FFF8F1), VOM Orange (#FF7E36)
/// 
/// PageController를 사용하여 bool 변수 지옥에서 벗어나 우아하게 화면 전환을 제어합니다.
class CareOnboardingScreen extends StatefulWidget {
  const CareOnboardingScreen({super.key});

  @override
  State<CareOnboardingScreen> createState() => _CareOnboardingScreenState();
}

class _CareOnboardingScreenState extends State<CareOnboardingScreen> {
  // 1. 화면 제어 컨트롤러
  final PageController _pageController = PageController();
  final TtsService _ttsService = TtsService();

  // 2. 누적되는 사용자 데이터 (여기에 모입니다)
  String _userName = "";
  String _userPhone = "";
  List<String> _userInterests = [];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // TTS 초기화 등 전역 설정
    _ttsService.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  // --- [핵심] 네비게이션 로직 ---

  // 다음 페이지로 부드럽게 이동
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 1000), // 어머니들을 위해 천천히
      curve: Curves.easeInOutQuart,
    );
  }

  // 이전 페이지로 이동 (뒤로가기)
  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // --- [핵심] 데이터 업데이트 로직 ---

  void _updateName(String name) {
    setState(() => _userName = name);
    _nextPage(); // 저장 후 다음으로
  }

  void _onPhoneSubmitted(String phone) {
    setState(() => _userPhone = phone);
    // 실제로는 여기서 SMS 발송 API 호출
    _nextPage();
  }

  void _onOtpVerified() {
    // 인증 성공 처리
    _nextPage();
  }

  // Step 8 완료 콜백 수정
  void _onInterestsSelected(List<String> interests) {
    setState(() {
      _userInterests = interests;
    });
    _nextPage(); // Step 8 -> Step 9로 이동
  }

  // Step 9 완료 콜백 (단순 이동)
  void _onProcessingComplete() {
    _nextPage(); // Step 9 -> Step 10으로 이동
  }

  Future<void> _onOnboardingComplete() async {
    // 백엔드 저장 로직
    await onboardingBackend.updateStep(
      step: 'completed',
      name: _userName,
      interests: _userInterests,
    );

    // 온보딩 완료 후 홈 화면으로 이동
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const TagWaitScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 시스템 뒤로가기 막음 (앱 종료 방지)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 첫 페이지가 아니면 이전 페이지로 이동
        if (_currentIndex > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          // 첫 페이지면 앱 종료 알림 띄우기 등의 로직
          // (현재는 아무 동작 없음 - 필요시 추가 가능)
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F1), // VOM Beige
        resizeToAvoidBottomInset: false,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // 사용자가 맘대로 스와이프 못하게
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            // [Step 0] 스플래시
            Step00Splash(onNext: _nextPage),

            // [Step 1] 환영
            Step01Welcome(onNext: _nextPage),

            // [Step 2] 로딩
            Step02Loading(onLoadingComplete: _nextPage),

            // [Step 3] 카드 소개 (이름 없음)
            Step03CardIntro(userName: _userName, onNext: _nextPage),

            // [Step 4] 이름 입력
            Step04NameInput(
              currentName: _userName, // 혹시 뒤로 돌아왔을 때 데이터 유지
              onNameSubmitted: _updateName, // 입력 완료 시 실행될 함수 전달
              onBack: _prevPage, // [핵심] 뒤로가기 함수 전달
            ),

            // [Step 5] 휴대폰 번호 확인
            Step05PhoneCheck(
              userName: _userName,
              onNext: _onPhoneSubmitted,
              onBack: _prevPage, // [핵심] 뒤로가기 함수 전달
            ),

            // [Step 6] 인증번호 입력 (앞에서 받은 번호 전달)
            Step06OtpInput(
              phoneNumber: _userPhone,
              onNext: _onOtpVerified,
            ),

            // [Step 7] 인증 성공 (도장 쾅!)
            Step07VerificationSuccess(
              userName: _userName,
              onNext: _nextPage, // 다음 단계(관심사 선택)로
            ),

            // [Step 8] 관심사 선택
            Step08Interests(
              onComplete: _onInterestsSelected,
            ),

            // [NEW Step 9] 학생증 발급 중 (브릿지 화면)
            Step09Processing(
              onNext: _onProcessingComplete,
            ),

            // [Step 10] 최종 입학 완료 (이제 여기로 넘어옴)
            Step10Completion(
              name: _userName,
              interests: _userInterests,
              onFinish: _onOnboardingComplete,
            ),
          ],
        ),
      ),
    );
  }
}
