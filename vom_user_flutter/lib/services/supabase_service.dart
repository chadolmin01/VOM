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

  /// 학습 로그 전송
  Future<bool> sendLearningLog({
    required String cardName,
    required String cardIcon,
    String? speechText,
    bool? quizCorrect,
    List<String>? riskKeywords,
  }) async {
    if (!isConfigured || _client == null) {
      debugPrint('⚠️ Supabase not configured. Log not sent.');
      return false;
    }

    try {
      await _client!.from('learning_logs').insert({
        'device_id': deviceId,
        'card_name': cardName,
        'card_icon': cardIcon,
        'speech_text': speechText,
        'quiz_correct': quizCorrect,
        'risk_keywords': riskKeywords,
        'completed_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Learning log sent: $cardName');
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
