import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase 설정
  static const String _supabaseUrl = 'https://ahcxzoqgetygljefifgr.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoY3h6b3FnZXR5Z2xqZWZpZmdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMTg0MDUsImV4cCI6MjA4MzY5NDQwNX0.WVGNLC63tyW5Oq074yN0LItm3HbzglpCOo67XcILx_c';

  SupabaseClient? _client;
  String? _deviceId;

  bool get isConfigured =>
      _supabaseUrl != 'YOUR_SUPABASE_URL' &&
      _supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call init() first.');
    }
    return _client!;
  }

  Future<void> init() async {
    if (!isConfigured) {
      debugPrint('⚠️ Supabase not configured. Running in offline mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _client = Supabase.instance.client;

      // 디바이스 ID 생성 또는 가져오기
      _deviceId = await _getOrCreateDeviceId();

      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    // 간단한 디바이스 ID 생성 (실제로는 device_info_plus 사용 권장)
    final existingId = _client?.auth.currentUser?.id;
    if (existingId != null) return existingId;

    // 익명 사용자용 랜덤 ID
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  String get deviceId => _deviceId ?? 'unknown_device';

  // ============================================================
  // Auth: 회원가입 및 로그인
  // ============================================================

  /// 이메일/비밀번호로 회원가입
  /// auth.users에 저장되면 트리거가 자동으로 profiles 테이블에 복사
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? userType,
    String? region,
  }) async {
    if (!isConfigured || _client == null) {
      return {'success': false, 'error': 'Supabase가 초기화되지 않았습니다.'};
    }

    try {
      // 1단계: Supabase Auth에 회원가입 (auth.users 테이블에 저장)
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name ?? email.split('@')[0], // metadata에 name 저장
          if (phone != null) 'phone': phone,
          if (userType != null) 'user_type': userType,
          if (region != null) 'region': region,
        },
      );

      if (response.user == null) {
        return {'success': false, 'error': '회원가입에 실패했습니다.'};
      }

      // 2단계: 트리거가 자동으로 profiles 테이블에 복사하지만,
      // 추가 정보(phone, user_type, region)를 업데이트
      if (phone != null || userType != null || region != null) {
        try {
          await _client!.from('profiles').update({
            if (phone != null) 'phone': phone,
            if (userType != null) 'user_type': userType,
            if (region != null) 'region': region,
          }).eq('id', response.user!.id);
        } catch (e) {
          // 프로필 업데이트 실패해도 회원가입은 성공으로 처리
          debugPrint('⚠️ 프로필 업데이트 실패 (회원가입은 성공): $e');
        }
      }

      debugPrint('✅ 회원가입 성공: ${response.user!.email}');
      return {
        'success': true,
        'user': response.user,
        'message': '회원가입이 완료되었습니다.',
      };
    } catch (e) {
      debugPrint('❌ 회원가입 실패: $e');
      return {
        'success': false,
        'error': e.toString().contains('already registered')
            ? '이미 등록된 이메일입니다.'
            : '회원가입 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    if (!isConfigured || _client == null) {
      return {'success': false, 'error': 'Supabase가 초기화되지 않았습니다.'};
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {'success': false, 'error': '로그인에 실패했습니다.'};
      }

      // device_id 업데이트
      _deviceId = response.user!.id;

      debugPrint('✅ 로그인 성공: ${response.user!.email}');
      return {
        'success': true,
        'user': response.user,
      };
    } catch (e) {
      debugPrint('❌ 로그인 실패: $e');
      return {
        'success': false,
        'error': e.toString().contains('Invalid login credentials')
            ? '이메일 또는 비밀번호가 올바르지 않습니다.'
            : '로그인 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 전화번호로 OTP 전송
  Future<Map<String, dynamic>> signInWithPhone({
    required String phoneNumber,
  }) async {
    if (!isConfigured || _client == null) {
      return {'success': false, 'error': 'Supabase가 초기화되지 않았습니다.'};
    }

    try {
      // 전화번호 정리 (010-1234-5678 -> +821012345678)
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final formattedPhone = cleaned.startsWith('0')
          ? '+82${cleaned.substring(1)}'
          : '+82$cleaned';

      final response = await _client!.auth.signInWithOtp(
        phone: formattedPhone,
      );

      debugPrint('✅ OTP 전송 성공: $formattedPhone');
      return {
        'success': true,
        'message': '인증 코드가 전송되었습니다.',
      };
    } catch (e) {
      debugPrint('❌ OTP 전송 실패: $e');
      return {
        'success': false,
        'error': '인증 코드 전송 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// OTP 코드 검증
  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (!isConfigured || _client == null) {
      return {'success': false, 'error': 'Supabase가 초기화되지 않았습니다.'};
    }

    try {
      // 전화번호 정리
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final formattedPhone = cleaned.startsWith('0')
          ? '+82${cleaned.substring(1)}'
          : '+82$cleaned';

      final response = await _client!.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user == null) {
        return {'success': false, 'error': '인증에 실패했습니다.'};
      }

      // device_id 업데이트
      _deviceId = response.user!.id;

      // 프로필에 전화번호와 온보딩 단계 저장
      try {
        await _client!.from('profiles').update({
          'phone': phoneNumber,
          'onboarding_step': 'phone_verified',
          'onboarding_last_activity_at': DateTime.now().toIso8601String(),
        }).eq('id', response.user!.id);
      } catch (e) {
        debugPrint('⚠️ 프로필 업데이트 실패 (인증은 성공): $e');
      }

      debugPrint('✅ OTP 인증 성공: ${response.user!.id}');
      return {
        'success': true,
        'user': response.user,
        'message': '인증이 완료되었습니다.',
      };
    } catch (e) {
      debugPrint('❌ OTP 인증 실패: $e');
      return {
        'success': false,
        'error': e.toString().contains('Invalid') || e.toString().contains('expired')
            ? '인증 코드가 올바르지 않거나 만료되었습니다.'
            : '인증 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 온보딩 진행 단계 업데이트
  Future<bool> updateOnboardingStep({
    required String step, // 'phone_verified', 'name_entered', 'interests_selected', 'completed'
    String? name,
    List<String>? interests,
  }) async {
    if (!isConfigured || _client == null) return false;

    final user = _client!.auth.currentUser;
    if (user == null) return false;

    try {
      final updateData = <String, dynamic>{
        'onboarding_step': step,
      };

      if (name != null) {
        updateData['name'] = name;
      }

      if (interests != null) {
        updateData['interests'] = interests;
      }

      await _client!.from('profiles').update(updateData).eq('id', user.id);

      debugPrint('✅ 온보딩 단계 업데이트: $step');
      return true;
    } catch (e) {
      debugPrint('❌ 온보딩 단계 업데이트 실패: $e');
      return false;
    }
  }

  /// 온보딩 진행 상황 저장 (이름, 관심 분야 등)
  Future<bool> saveOnboardingProgress({
    String? name,
    List<String>? interests,
    String? step,
  }) async {
    if (!isConfigured || _client == null) return false;

    final user = _client!.auth.currentUser;
    if (user == null) return false;

    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }

      if (interests != null) {
        updateData['interests'] = interests;
      }

      if (step != null) {
        updateData['onboarding_step'] = step;
      }

      await _client!.from('profiles').update(updateData).eq('id', user.id);

      debugPrint('✅ 온보딩 진행 상황 저장 완료');
      return true;
    } catch (e) {
      debugPrint('❌ 온보딩 진행 상황 저장 실패: $e');
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    if (_client == null) return;

    try {
      await _client!.auth.signOut();
      _deviceId = null;
      debugPrint('✅ 로그아웃 완료');
    } catch (e) {
      debugPrint('❌ 로그아웃 실패: $e');
    }
  }

  /// 현재 로그인한 사용자 정보 가져오기
  User? get currentUser => _client?.auth.currentUser;

  /// 프로필 정보 가져오기 (profiles 테이블)
  Future<Map<String, dynamic>?> getProfile() async {
    if (!isConfigured || _client == null) return null;

    final user = _client!.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client!
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('❌ 프로필 조회 실패: $e');
      return null;
    }
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? userType,
    String? region,
  }) async {
    if (!isConfigured || _client == null) return false;

    final user = _client!.auth.currentUser;
    if (user == null) return false;

    try {
      await _client!.from('profiles').update({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (userType != null) 'user_type': userType,
        if (region != null) 'region': region,
      }).eq('id', user.id);

      debugPrint('✅ 프로필 업데이트 성공');
      return true;
    } catch (e) {
      debugPrint('❌ 프로필 업데이트 실패: $e');
      return false;
    }
  }

  /// 학습 로그 전송 (확장된 필드 포함)
  Future<bool> sendLearningLog({
    required String cardName,
    required String cardIcon,
    String? cardId,
    String? speechText,
    bool? quizCorrect,
    List<String>? riskKeywords,
    int? reactionTime,
    int retryCount = 0,
    double? riskScore,
    DateTime? taggedAt,
    DateTime? completedAt,
  }) async {
    if (!isConfigured || _client == null) {
      debugPrint('⚠️ Supabase not configured. Log not sent.');
      return false;
    }

    try {
      final logData = {
        'device_id': deviceId,
        if (cardId != null) 'card_id': cardId,
        'card_name': cardName,
        if (cardIcon.isNotEmpty) 'card_icon': cardIcon,
        if (speechText != null && speechText.isNotEmpty)
          'speech_text': speechText,
        if (quizCorrect != null) 'quiz_correct': quizCorrect,
        if (riskKeywords != null && riskKeywords.isNotEmpty)
          'risk_keywords': riskKeywords,
        if (reactionTime != null) 'reaction_time': reactionTime,
        'retry_count': retryCount,
        if (riskScore != null) 'risk_score': riskScore,
        if (taggedAt != null) 'tagged_at': taggedAt.toIso8601String(),
        'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
      };

      await _client!.from('learning_logs').insert(logData);

      debugPrint('✅ Learning log sent: $cardName (reaction_time: $reactionTime, retry_count: $retryCount, risk_score: $riskScore)');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to send learning log: $e');
      return false;
    }
  }

  /// 사용자 등록/업데이트
  Future<bool> registerUser({
    String? name,
    String? userType,
    String? region,
  }) async {
    if (!isConfigured || _client == null) return false;

    try {
      await _client!.from('users').upsert({
        'device_id': deviceId,
        'name': name,
        'user_type': userType,
        'region': region,
        'last_active_at': DateTime.now().toIso8601String(),
      }, onConflict: 'device_id');

      debugPrint('✅ User registered/updated');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to register user: $e');
      return false;
    }
  }

  /// 마지막 활동 시간 업데이트
  Future<void> updateLastActive() async {
    if (!isConfigured || _client == null) return;

    try {
      await _client!.from('users').update({
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('device_id', deviceId);
    } catch (e) {
      debugPrint('Failed to update last active: $e');
    }
  }

  // ============================================================
  // NFC/QR 카드 매핑 조회
  // ============================================================

  /// NFC 태그 ID로 카드 정보 조회
  Future<Map<String, dynamic>?> getCardMappingByNfcTagId(String tagId) async {
    if (!isConfigured || _client == null) return null;

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select()
          .eq('nfc_tag_id', tagId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Failed to get NFC mapping: $e');
      return null;
    }
  }

  /// QR 코드로 카드 정보 조회
  Future<Map<String, dynamic>?> getCardMappingByQrCode(String qrCode) async {
    if (!isConfigured || _client == null) return null;

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select()
          .eq('qr_code', qrCode)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Failed to get QR mapping: $e');
      return null;
    }
  }

  // ============================================================
  // 카드 콘텐츠 관련 (v2 - UID 매핑 방식)
  // ============================================================

  /// NFC 태그 ID로 콘텐츠 전체 조회 (매핑 + 콘텐츠 join)
  Future<Map<String, dynamic>?> getContentByNfcTagId(String tagId) async {
    if (!isConfigured || _client == null) return null;

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select('*, card_contents(*)')
          .eq('nfc_tag_id', tagId)
          .maybeSingle();

      if (response != null && response['card_contents'] != null) {
        return response['card_contents'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get content by NFC tag: $e');
      return null;
    }
  }

  /// QR 코드로 콘텐츠 전체 조회 (매핑 + 콘텐츠 join)
  Future<Map<String, dynamic>?> getContentByQrCode(String qrCode) async {
    if (!isConfigured || _client == null) return null;

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select('*, card_contents(*)')
          .eq('qr_code', qrCode)
          .maybeSingle();

      if (response != null && response['card_contents'] != null) {
        return response['card_contents'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get content by QR code: $e');
      return null;
    }
  }

  /// 카드 ID로 콘텐츠 직접 조회
  Future<Map<String, dynamic>?> getContentById(String cardId) async {
    if (!isConfigured || _client == null) return null;

    try {
      final response = await _client!
          .from('card_contents')
          .select()
          .eq('id', cardId)
          .eq('is_active', true)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Failed to get content by ID: $e');
      return null;
    }
  }
}
