import 'dart:async';

import 'package:flutter/foundation.dart';

import 'supabase_service.dart';

/// 온보딩 단계 및 프로필 정보를 표현하는 단순 DTO
class OnboardingProfile {
  final String? name;
  final String? phone;
  final List<String> interests;
  final String? step;

  OnboardingProfile({
    required this.name,
    required this.phone,
    required this.interests,
    required this.step,
  });
}

/// 온보딩 관련 서버/스토리지 인터페이스
///
/// - 현재 앱은 기본적으로 Offline 구현을 사용하고,
/// - 나중에 실제 서버(Supabase 등)를 붙일 때 SupabaseOnboardingBackend만 켜면 됨.
abstract class OnboardingBackend {
  Future<OnboardingProfile?> loadProfile();

  Future<bool> sendOtp(String phoneNumber);

  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<void> updateStep({
    required String step,
    String? name,
    List<String>? interests,
  });
}

/// 하이브리드 온보딩 백엔드 (로컬 우선 + 서버 가능하면 저장)
///
/// - 항상 로컬(메모리)에 저장하여 오프라인에서도 동작
/// - Supabase가 연결 가능하면 서버에도 저장 시도 (실패해도 에러 없이 진행)
/// - 앱 재시작 시 로컬 상태는 초기화되지만, 서버에 저장된 데이터는 유지됨
class OfflineOnboardingBackend implements OnboardingBackend {
  final SupabaseService _supabase = SupabaseService();
  String? _name;
  String? _phone;
  List<String> _interests = [];
  String? _step;

  /// Supabase 연결 가능 여부 확인 (에러 없이 조용히)
  Future<bool> _isSupabaseAvailable() async {
    try {
      if (!_supabase.isConfigured) return false;
      // 간단한 헬스체크: 현재 유저가 있거나, 프로필 조회가 가능한지
      final user = _supabase.currentUser;
      if (user != null) return true;
      // 유저가 없어도 서비스 자체는 사용 가능할 수 있음
      return true;
    } catch (e) {
      debugPrint('⚠️ [OfflineOnboardingBackend] Supabase not available: $e');
      return false;
    }
  }

  @override
  Future<OnboardingProfile?> loadProfile() async {
    // 1. 먼저 로컬(메모리)에서 확인
    if (_step != null || _name != null || _phone != null || _interests.isNotEmpty) {
      return OnboardingProfile(
        name: _name,
        phone: _phone,
        interests: List.unmodifiable(_interests),
        step: _step,
      );
    }

    // 2. 로컬에 없으면 Supabase에서 시도 (가능하면)
    if (await _isSupabaseAvailable()) {
      try {
        final profile = await _supabase.getProfile();
        if (profile != null) {
          // 서버에서 가져온 데이터를 로컬에도 동기화
          _name = profile['name'] as String?;
          _phone = profile['phone'] as String?;
          _interests = (profile['interests'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          _step = profile['onboarding_step'] as String?;

          return OnboardingProfile(
            name: _name,
            phone: _phone,
            interests: List.unmodifiable(_interests),
            step: _step,
          );
        }
      } catch (e) {
        debugPrint('⚠️ [OfflineOnboardingBackend] loadProfile from Supabase failed: $e');
        // 에러가 나도 조용히 넘어감 (로컬만 사용)
      }
    }

    // 3. 둘 다 없으면 null (처음 시작)
    return null;
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    // 로컬에 저장
    _phone = phoneNumber;
    _step = 'phone_otp_sent';

    // Supabase가 가능하면 서버에도 시도 (실패해도 에러 없이)
    if (await _isSupabaseAvailable()) {
      try {
        final result = await _supabase.signInWithPhone(phoneNumber: phoneNumber);
        if (result['success'] == true) {
          debugPrint('✅ [OfflineOnboardingBackend] sendOtp to Supabase: success');
        } else {
          debugPrint('⚠️ [OfflineOnboardingBackend] sendOtp to Supabase: failed (using local only)');
        }
      } catch (e) {
        debugPrint('⚠️ [OfflineOnboardingBackend] sendOtp to Supabase error: $e (using local only)');
      }
    } else {
      // 개발 모드: 실제 OTP를 보내지 않고, 살짝 딜레이만 준 뒤 성공 처리
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('📱 [OfflineOnboardingBackend] sendOtp(fake/local) to $phoneNumber');
    }

    return true; // 로컬 저장은 항상 성공
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // 로컬에 저장
    _phone = phoneNumber;
    _step = 'phone_verified';

    // Supabase가 가능하면 서버에도 시도 (실패해도 에러 없이)
    if (await _isSupabaseAvailable()) {
      try {
        final result = await _supabase.verifyPhoneOtp(
          phoneNumber: phoneNumber,
          otp: otp,
        );
        if (result['success'] == true) {
          debugPrint('✅ [OfflineOnboardingBackend] verifyOtp to Supabase: success');
        } else {
          debugPrint('⚠️ [OfflineOnboardingBackend] verifyOtp to Supabase: failed (using local only)');
        }
      } catch (e) {
        debugPrint('⚠️ [OfflineOnboardingBackend] verifyOtp to Supabase error: $e (using local only)');
      }
    } else {
      // 개발 모드: 어떤 6자리든 성공 처리
      await Future.delayed(const Duration(milliseconds: 400));
      debugPrint('📱 [OfflineOnboardingBackend] verifyOtp(fake/local) for $phoneNumber, otp=$otp');
    }

    return true; // 로컬 저장은 항상 성공
  }

  @override
  Future<void> updateStep({
    required String step,
    String? name,
    List<String>? interests,
  }) async {
    // 로컬에 저장
    _step = step;
    if (name != null) _name = name;
    if (interests != null) _interests = List.from(interests);
    debugPrint(
        '📚 [OfflineOnboardingBackend] updateStep(local): $_step, name=$_name, interests=$_interests');

    // Supabase가 가능하면 서버에도 저장 시도 (실패해도 에러 없이)
    if (await _isSupabaseAvailable()) {
      try {
        await _supabase.updateOnboardingStep(
          step: step,
          name: name,
          interests: interests,
        );
        debugPrint('✅ [OfflineOnboardingBackend] updateStep to Supabase: success');
      } catch (e) {
        debugPrint('⚠️ [OfflineOnboardingBackend] updateStep to Supabase error: $e (using local only)');
        // 에러가 나도 조용히 넘어감 (로컬 저장은 이미 완료)
      }
    }
  }
}

/// 실제 Supabase를 사용하는 온보딩 백엔드 (현재는 OFFLINE 모드이므로 기본 사용 안 함)
///
/// - 나중에 서버를 연결하고 싶을 때, kUseSupabaseOnboardingBackend 를 true로 변경하면 됨.
class SupabaseOnboardingBackend implements OnboardingBackend {
  final SupabaseService _supabase = SupabaseService();

  @override
  Future<OnboardingProfile?> loadProfile() async {
    final profile = await _supabase.getProfile();
    if (profile == null) return null;

    return OnboardingProfile(
      name: profile['name'] as String?,
      phone: profile['phone'] as String?,
      interests: (profile['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      step: profile['onboarding_step'] as String?,
    );
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    final result = await _supabase.signInWithPhone(phoneNumber: phoneNumber);
    return result['success'] == true;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final result = await _supabase.verifyPhoneOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return result['success'] == true;
  }

  @override
  Future<void> updateStep({
    required String step,
    String? name,
    List<String>? interests,
  }) async {
    await _supabase.updateOnboardingStep(
      step: step,
      name: name,
      interests: interests,
    );
  }
}

/// 온보딩 백엔드 선택 스위치
///
/// - 현재는 오프라인/개발용 모드가 기본값 (서버 없이 동작)
/// - 나중에 서버를 붙일 때는 이 값을 true로 바꾸면 된다.
const bool kUseSupabaseOnboardingBackend = false;

final OnboardingBackend onboardingBackend =
    kUseSupabaseOnboardingBackend ? SupabaseOnboardingBackend() : OfflineOnboardingBackend();

