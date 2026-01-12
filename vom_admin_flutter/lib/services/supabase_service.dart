import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/learning_log.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase 설정
  static const String _supabaseUrl = 'https://ahcxzoqgetygljefifgr.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoY3h6b3FnZXR5Z2xqZWZpZmdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMTg0MDUsImV4cCI6MjA4MzY5NDQwNX0.WVGNLC63tyW5Oq074yN0LItm3HbzglpCOo67XcILx_c';

  SupabaseClient? _client;
  RealtimeChannel? _channel;

  final _logsController = StreamController<LearningLog>.broadcast();
  Stream<LearningLog> get onNewLog => _logsController.stream;

  bool get isConfigured =>
      _supabaseUrl != 'YOUR_SUPABASE_URL' &&
      _supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';

  SupabaseClient? get client => _client;

  Future<void> init() async {
    if (!isConfigured) {
      debugPrint('⚠️ Supabase not configured. Running in demo mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
    }
  }

  /// 기존 로그 불러오기
  Future<List<LearningLog>> fetchLogs({int limit = 50}) async {
    if (_client == null) return _getDemoLogs();

    try {
      final response = await _client!
          .from('learning_logs')
          .select()
          .order('completed_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => LearningLog.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch logs: $e');
      return _getDemoLogs();
    }
  }

  /// fetchRecentLogs alias
  Future<List<LearningLog>> fetchRecentLogs({int limit = 50}) async {
    return fetchLogs(limit: limit);
  }

  /// 콜백 기반 실시간 구독
  void subscribeToLogs(void Function(LearningLog log) onLog) {
    // 데모 모드면 무시
    if (_client == null) return;

    _channel = _client!
        .channel('learning_logs_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'learning_logs',
          callback: (payload) {
            final log = LearningLog.fromJson(payload.newRecord);
            onLog(log);
            debugPrint('📥 New log received: ${log.cardName}');
          },
        )
        .subscribe();

    debugPrint('🔔 Realtime subscription started');
  }

  /// 데모용 더미 로그 생성
  List<LearningLog> _getDemoLogs() {
    final now = DateTime.now();
    return [
      LearningLog(
        id: '1',
        deviceId: 'USER_001',
        cardName: '밥 먹이기',
        cardIcon: '🍼',
        speechText: '아기야 밥 먹자',
        quizCorrect: true,
        riskKeywords: null,
        completedAt: now.subtract(const Duration(minutes: 5)),
      ),
      LearningLog(
        id: '2',
        deviceId: 'USER_002',
        cardName: '기저귀 갈기',
        cardIcon: '👶',
        speechText: '기저귀 갈아줄게',
        quizCorrect: true,
        riskKeywords: null,
        completedAt: now.subtract(const Duration(minutes: 15)),
      ),
      LearningLog(
        id: '3',
        deviceId: 'USER_003',
        cardName: '목욕시키기',
        cardIcon: '🛁',
        speechText: '목욕하자 아기야',
        quizCorrect: false,
        riskKeywords: null,
        completedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// 실시간 구독 시작
  void startRealtimeSubscription() {
    if (_client == null) return;

    _channel = _client!
        .channel('learning_logs_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'learning_logs',
          callback: (payload) {
            final log = LearningLog.fromJson(payload.newRecord);
            _logsController.add(log);
            debugPrint('📥 New log received: ${log.cardName}');
          },
        )
        .subscribe();

    debugPrint('🔔 Realtime subscription started');
  }

  /// 실시간 구독 중지
  void stopRealtimeSubscription() {
    if (_channel != null) {
      _client?.removeChannel(_channel!);
      _channel = null;
      debugPrint('🔕 Realtime subscription stopped');
    }
  }

  void dispose() {
    stopRealtimeSubscription();
    _logsController.close();
  }

  // ============================================================
  // NFC/QR 카드 매핑 관련
  // ============================================================

  /// NFC 태그 ID로 매핑 저장
  Future<bool> saveNfcMapping({
    required String nfcTagId,
    required String cardId,
    required String cardName,
    String? cardIcon,
  }) async {
    if (_client == null) {
      debugPrint('⚠️ Supabase not configured');
      return false;
    }

    try {
      // 기존 매핑이 있으면 업데이트, 없으면 삽입
      await _client!.from('nfc_card_mappings').upsert({
        'nfc_tag_id': nfcTagId,
        'card_id': cardId,
        'card_name': cardName,
        'card_icon': cardIcon,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'nfc_tag_id');

      debugPrint('✅ NFC mapping saved: $nfcTagId -> $cardName');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save NFC mapping: $e');
      return false;
    }
  }

  /// QR 코드로 매핑 저장
  Future<bool> saveQrMapping({
    required String qrCode,
    required String cardId,
    required String cardName,
    String? cardIcon,
  }) async {
    if (_client == null) {
      debugPrint('⚠️ Supabase not configured');
      return false;
    }

    try {
      await _client!.from('nfc_card_mappings').upsert({
        'qr_code': qrCode,
        'card_id': cardId,
        'card_name': cardName,
        'card_icon': cardIcon,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'qr_code');

      debugPrint('✅ QR mapping saved: $qrCode -> $cardName');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save QR mapping: $e');
      return false;
    }
  }

  /// 모든 매핑 목록 조회
  Future<List<Map<String, dynamic>>> fetchAllMappings() async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select()
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch mappings: $e');
      return [];
    }
  }

  /// 매핑 삭제
  Future<bool> deleteMapping(String id) async {
    if (_client == null) return false;

    try {
      await _client!.from('nfc_card_mappings').delete().eq('id', id);
      debugPrint('✅ Mapping deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete mapping: $e');
      return false;
    }
  }

  // ============================================================
  // 카드 콘텐츠 관련 (v2 - UID 매핑 방식)
  // ============================================================

  /// 모든 카드 콘텐츠 조회
  Future<List<Map<String, dynamic>>> fetchCardContents() async {
    if (_client == null) return _getDemoCardContents();

    try {
      final response = await _client!
          .from('card_contents')
          .select()
          .eq('is_active', true)
          .order('id');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch card contents: $e');
      return _getDemoCardContents();
    }
  }

  /// 데모용 카드 콘텐츠
  List<Map<String, dynamic>> _getDemoCardContents() {
    return [
      {'id': '1', 'name': '체온계', 'icon': '🌡️'},
      {'id': '2', 'name': '약병', 'icon': '💊'},
      {'id': '3', 'name': '치약', 'icon': '🦷'},
    ];
  }

  /// NFC 태그 ID로 매핑 저장 (v2 - 라벨 포함)
  Future<bool> saveNfcMappingV2({
    required String nfcTagId,
    required String cardId,
    String? label,
  }) async {
    if (_client == null) {
      debugPrint('⚠️ Supabase not configured');
      return false;
    }

    try {
      await _client!.from('nfc_card_mappings').upsert({
        'nfc_tag_id': nfcTagId,
        'card_id': cardId,
        'label': label,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'nfc_tag_id');

      debugPrint('✅ NFC mapping saved: $nfcTagId -> $cardId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save NFC mapping: $e');
      return false;
    }
  }

  /// 매핑 목록 조회 (콘텐츠 정보 포함)
  Future<List<Map<String, dynamic>>> fetchMappingsWithContent() async {
    if (_client == null) return [];

    try {
      final response = await _client!
          .from('nfc_card_mappings')
          .select('*, card_contents(*)')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch mappings with content: $e');
      return [];
    }
  }
}
