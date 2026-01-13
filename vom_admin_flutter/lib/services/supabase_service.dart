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

  /// Supabase 클라이언트 가져오기 (직접 인스턴스 참조)
  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('⚠️ Supabase.instance.client 접근 실패: $e');
      return _client; // 폴백으로 저장된 클라이언트 반환
    }
  }

  Future<void> init() async {
    if (!isConfigured) {
      debugPrint('⚠️ Supabase not configured. Running in demo mode.');
      _client = null;
      return;
    }

    try {
      debugPrint('🔄 Initializing Supabase...');
      debugPrint('📍 URL: $_supabaseUrl');
      debugPrint('🔑 Anon Key: ${_supabaseAnonKey.substring(0, 20)}...');
      
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      
      _client = Supabase.instance.client;
      
      if (_client == null) {
        debugPrint('❌ Supabase.instance.client is null after initialization');
        return;
      }
      
      debugPrint('✅ Supabase client created');
      
      // 연결 테스트 (타임아웃 설정)
      try {
        final testResponse = await _client!
            .from('card_contents')
            .select('id')
            .limit(1)
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ Supabase initialized successfully');
        debugPrint('✅ Connection test passed: $testResponse');
      } catch (testError) {
        debugPrint('⚠️ Connection test failed: $testError');
        debugPrint('⚠️ Supabase client exists but connection test failed');
        // 클라이언트는 있지만 연결 테스트 실패 - 클라이언트는 유지
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Supabase initialization failed: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _client = null;
      
      // 더 자세한 에러 정보
      if (e.toString().contains('SocketException') || e.toString().contains('network')) {
        debugPrint('🌐 네트워크 연결 문제로 보입니다. 인터넷 연결을 확인하세요.');
      } else if (e.toString().contains('timeout')) {
        debugPrint('⏱️ 연결 타임아웃이 발생했습니다. Supabase 서버 상태를 확인하세요.');
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        debugPrint('🔐 인증 오류: API 키를 확인하세요.');
      }
    }
  }

  /// Supabase 초기화 상태 확인 및 재시도
  Future<bool> ensureInitialized() async {
    try {
      final supabase = Supabase.instance.client;
      if (supabase != null) {
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Supabase.instance 접근 실패: $e');
    }

    debugPrint('🔄 Supabase client is null, attempting to reinitialize...');
    await init();
    
    try {
      final supabase = Supabase.instance.client;
      return supabase != null;
    } catch (e) {
      debugPrint('❌ 재초기화 후에도 클라이언트를 가져올 수 없습니다: $e');
      return false;
    }
  }

  // ============================================================
  // Supabase 연결 테스트 함수
  // ============================================================
  /// Supabase 연결 상태를 상세히 테스트
  Future<Map<String, dynamic>> testConnection() async {
    final result = {
      'url': _supabaseUrl,
      'isConfigured': isConfigured,
      'clientExists': false,
      'connectionTest': false,
      'error': null,
      'details': <String, dynamic>{},
    };

    try {
      // 1. 설정 확인
      if (!isConfigured) {
        result['error'] = 'Supabase 설정이 완료되지 않았습니다';
        return result;
      }

      // 2. 클라이언트 존재 확인
      try {
        final supabase = Supabase.instance.client;
        result['clientExists'] = supabase != null;
        
        if (supabase == null) {
          result['error'] = 'Supabase.instance.client가 null입니다';
          (result['details'] as Map<String, dynamic>)['suggestion'] = '앱을 재시작하거나 Supabase.initialize()를 다시 호출하세요';
          return result;
        }

        // 3. 연결 테스트 (card_contents 테이블 조회)
        try {
          final testResponse = await supabase
              .from('card_contents')
              .select('id')
              .limit(1)
              .timeout(const Duration(seconds: 10));
          
          result['connectionTest'] = true;
          final details = result['details'] as Map<String, dynamic>;
          details['testResponse'] = testResponse;
          details['message'] = '연결 성공!';
          details['tableExists'] = true;
        } catch (testError) {
          result['error'] = '연결 테스트 실패: $testError';
          final details = result['details'] as Map<String, dynamic>;
          details['testError'] = testError.toString();
          
          // 테이블 존재 여부 확인
          final errorStr = testError.toString().toLowerCase();
          if (errorStr.contains('relation') && errorStr.contains('does not exist')) {
            details['suggestion'] = '❌ 테이블이 존재하지 않습니다!\n\nSupabase 대시보드에서 다음을 확인하세요:\n1. SQL Editor 열기\n2. supabase_schema.sql 파일 내용 실행\n3. card_contents, nfc_card_mappings 테이블 생성 확인';
            details['tableExists'] = false;
          } else if (errorStr.contains('timeout')) {
            details['suggestion'] = '네트워크 연결이 느리거나 Supabase 서버 응답이 없습니다';
          } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
            details['suggestion'] = 'API 키가 잘못되었거나 만료되었습니다. Supabase 대시보드에서 API 키를 확인하세요';
          } else if (errorStr.contains('404') || errorStr.contains('not found')) {
            details['suggestion'] = '테이블이 존재하지 않습니다. supabase_schema.sql을 Supabase SQL Editor에서 실행하세요';
            details['tableExists'] = false;
          } else if (errorStr.contains('permission') || errorStr.contains('policy')) {
            details['suggestion'] = 'RLS 정책 문제입니다. Supabase 대시보드에서 RLS 정책을 확인하세요';
          }
        }
        
        // 4. nfc_card_mappings 테이블도 확인
        try {
          await supabase
              .from('nfc_card_mappings')
              .select('id')
              .limit(1)
              .timeout(const Duration(seconds: 5));
          (result['details'] as Map<String, dynamic>)['mappingsTableExists'] = true;
        } catch (mappingError) {
          final errorStr = mappingError.toString().toLowerCase();
          final details = result['details'] as Map<String, dynamic>;
          if (errorStr.contains('relation') && errorStr.contains('does not exist')) {
            details['mappingsTableExists'] = false;
            details['suggestion'] = '❌ nfc_card_mappings 테이블이 존재하지 않습니다!\n\nsupabase_schema.sql을 Supabase SQL Editor에서 실행하세요';
          }
        }
      } catch (clientError) {
        result['error'] = '클라이언트 접근 실패: $clientError';
        (result['details'] as Map<String, dynamic>)['clientError'] = clientError.toString();
      }
    } catch (e, stackTrace) {
      result['error'] = '테스트 중 예외 발생: $e';
      (result['details'] as Map<String, dynamic>)['stackTrace'] = stackTrace.toString();
    }

    return result;
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
    final supabase = Supabase.instance.client;
    if (supabase == null) {
      debugPrint('❌ 에러: Supabase 클라이언트가 초기화되지 않았습니다.');
      debugPrint('⚠️ 더미 데이터를 반환하지 않습니다. Supabase 연결을 확인하세요.');
      return []; // 더미 데이터 대신 빈 리스트 반환
    }

    try {
      final response = await supabase
          .from('card_contents')
          .select()
          .eq('is_active', true)
          .order('id');

      final contents = List<Map<String, dynamic>>.from(response);
      debugPrint('✅ 카드 콘텐츠 조회 성공: ${contents.length}개');
      return contents;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to fetch card contents: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      // 에러 발생 시에도 더미 데이터 반환하지 않음
      return [];
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

  // ============================================================
  // Supabase 에러 파싱 함수
  // ============================================================
  /// Supabase 에러를 파싱하여 사용자 친화적인 메시지로 변환
  /// public으로 변경하여 다른 곳에서도 사용 가능
  Map<String, String> parseSupabaseError(dynamic error) {
    String errorStr = '';
    String originalError = '';
    int? statusCode;
    String? errorCode;
    String? errorMessage;
    
    // PostgrestException인 경우 직접 파싱
    if (error is PostgrestException) {
      statusCode = error.code != null ? int.tryParse(error.code!) : null;
      errorCode = error.code;
      errorMessage = error.message;
      errorStr = error.toString();
      originalError = 'PostgrestException(code: ${error.code}, message: ${error.message}, details: ${error.details}, hint: ${error.hint})';
    } else {
      errorStr = error.toString();
      originalError = errorStr;
      
      // HTTP 상태 코드 추출 (문자열에서)
      final statusMatch = RegExp(r'\b(400|401|403|404|409|422|500|101)\b').firstMatch(errorStr);
      if (statusMatch != null) {
        statusCode = int.tryParse(statusMatch.group(1)!);
      }
    }

    String userMessage = '알 수 없는 오류가 발생했습니다';
    String errorType = 'Unknown';

    // 중복 키 오류 (UNIQUE 제약조건 위반)
    if (errorStr.toLowerCase().contains('duplicate key') || 
        errorStr.toLowerCase().contains('unique constraint') ||
        errorStr.toLowerCase().contains('already exists') ||
        errorStr.toLowerCase().contains('23505') || // PostgreSQL unique violation error code
        statusCode == 409) {
      errorType = 'Duplicate';
      if (errorStr.toLowerCase().contains('nfc_tag_id')) {
        userMessage = '❌ 중복 오류: 이 NFC 태그 ID는 이미 등록되어 있습니다.\n\n같은 NFC 태그를 다시 등록할 수 없습니다.';
      } else if (errorStr.toLowerCase().contains('qr_code')) {
        userMessage = '❌ 중복 오류: 이 QR 코드는 이미 등록되어 있습니다.';
      } else {
        userMessage = '❌ 중복 오류: 이미 존재하는 데이터입니다.\n\n이미 등록된 NFC 태그나 QR 코드입니다.';
      }
    }
    // 외래 키 오류 (card_id가 card_contents에 없음)
    else if (errorStr.contains('foreign key') || 
             errorStr.contains('violates foreign key constraint') ||
             errorStr.contains('card_contents')) {
      errorType = 'ForeignKey';
      userMessage = '❌ 데이터 오류: 선택한 콘텐츠(card_id)가 데이터베이스에 존재하지 않습니다.\n\n콘텐츠 목록을 새로고침하거나 다른 콘텐츠를 선택하세요.';
    }
    // 데이터 타입 오류
    else if (errorStr.contains('invalid input syntax') ||
             errorStr.contains('type mismatch') ||
             statusCode == 422) {
      errorType = 'DataType';
      userMessage = '❌ 데이터 형식 오류: 전송한 데이터의 형식이 올바르지 않습니다.\n\nNFC 태그 ID 형식을 확인하세요.';
    }
    // 권한 오류 (RLS 정책)
    else if (errorStr.contains('permission denied') ||
             errorStr.contains('new row violates row-level security') ||
             statusCode == 403) {
      errorType = 'Permission';
      userMessage = '❌ 권한 오류: 데이터베이스 쓰기 권한이 없습니다.\n\nSupabase RLS 정책을 확인하세요.';
    }
    // 테이블 없음
    else if (errorStr.contains('relation') && errorStr.contains('does not exist') ||
             statusCode == 404) {
      errorType = 'TableNotFound';
      userMessage = '❌ 테이블 없음: nfc_card_mappings 테이블이 존재하지 않습니다.\n\nsupabase_schema.sql을 Supabase SQL Editor에서 실행하세요.';
    }
    // 인증 오류
    else if (errorStr.contains('JWT') ||
             errorStr.contains('unauthorized') ||
             statusCode == 401) {
      errorType = 'Auth';
      userMessage = '❌ 인증 오류: API 키가 잘못되었거나 만료되었습니다.\n\nSupabase 대시보드에서 API 키를 확인하세요.';
    }
    // 네트워크/타임아웃
    else if (errorStr.contains('timeout') ||
             errorStr.contains('SocketException') ||
             errorStr.contains('network') ||
             statusCode == 101) {
      errorType = 'Network';
      userMessage = '❌ 네트워크 오류: 인터넷 연결을 확인하거나 잠시 후 다시 시도하세요.';
    }
    // 서버 오류
    else if (statusCode == 500) {
      errorType = 'Server';
      userMessage = '❌ 서버 오류: Supabase 서버에 문제가 발생했습니다.\n\n잠시 후 다시 시도하세요.';
    }
    // 기타 400번대 오류
    else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      errorType = 'ClientError';
      userMessage = '❌ 클라이언트 오류 (HTTP $statusCode): 요청 데이터가 올바르지 않습니다.';
    }

    return {
      'userMessage': userMessage,
      'errorType': errorType,
      'statusCode': statusCode?.toString() ?? 'Unknown',
      'errorCode': errorCode ?? 'Unknown',
      'originalError': originalError,
      'errorMessage': errorMessage ?? errorStr,
    };
  }

  /// NFC 태그 ID로 매핑 저장 (v2 - 라벨 포함)
  Future<bool> saveNfcMappingV2({
    required String nfcTagId,
    required String cardId,
    String? label,
  }) async {
    // Supabase.instance.client를 직접 참조
    final supabase = Supabase.instance.client;
    
    if (supabase == null) {
      debugPrint('❌ 에러: Supabase 클라이언트가 초기화되지 않았습니다.');
      debugPrint('🔄 Attempting to reinitialize...');
      final reinitialized = await ensureInitialized();
      if (!reinitialized) {
        debugPrint('❌ Failed to reinitialize Supabase client');
        return false;
      }
      // 재시도 후 다시 가져오기
      final retrySupabase = Supabase.instance.client;
      if (retrySupabase == null) {
        debugPrint('❌ Supabase 클라이언트를 가져올 수 없습니다.');
        return false;
      }
    }

    try {
      debugPrint('🔄 Attempting to save NFC mapping: $nfcTagId -> $cardId');
      debugPrint('📝 데이터: {nfc_tag_id: $nfcTagId, card_id: $cardId, label: $label}');
      
      // 직접 인스턴스 참조 사용
      final now = DateTime.now().toIso8601String();
      final response = await supabase!.from('nfc_card_mappings').upsert({
        'nfc_tag_id': nfcTagId,
        'card_id': cardId,
        'label': label,
        'created_at': now,  // 새로 생성될 때를 위해 명시
        'updated_at': now,
      }, onConflict: 'nfc_tag_id').select();

      debugPrint('✅ NFC mapping saved successfully: $nfcTagId -> $cardId');
      debugPrint('📦 Response: $response');
      return true;
    } on PostgrestException catch (e, stackTrace) {
      // PostgrestException 직접 처리
      final errorInfo = parseSupabaseError(e);
      debugPrint('❌ [PostgrestException] 전송 실패');
      debugPrint('📋 HTTP 상태 코드: ${errorInfo['statusCode']}');
      debugPrint('📋 에러 코드: ${errorInfo['errorCode']}');
      debugPrint('📋 에러 메시지: ${errorInfo['errorMessage']}');
      debugPrint('📋 원본 에러: ${errorInfo['originalError']}');
      debugPrint('📚 Stack trace: $stackTrace');
      
      // 에러를 다시 throw하여 상위에서 처리할 수 있도록
      throw Exception('${errorInfo['userMessage']}\n\nHTTP 상태 코드: ${errorInfo['statusCode']}\n에러 코드: ${errorInfo['errorCode']}\n원본 에러: ${errorInfo['originalError']}');
    } catch (e, stackTrace) {
      // 기타 에러 처리
      final errorInfo = parseSupabaseError(e);
      debugPrint('❌ [기타 에러] 전송 실패: $e');
      debugPrint('📋 파싱된 에러: $errorInfo');
      debugPrint('📚 Stack trace: $stackTrace');
      
      // 에러를 다시 throw하여 상위에서 처리할 수 있도록
      throw Exception('${errorInfo['userMessage']}\n\n원본 에러: ${errorInfo['originalError']}');
    }
  }

  /// 매핑 목록 조회 (콘텐츠 정보 포함)
  Future<List<Map<String, dynamic>>> fetchMappingsWithContent() async {
    final supabase = Supabase.instance.client;
    if (supabase == null) {
      debugPrint('⚠️ Supabase 클라이언트가 초기화되지 않았습니다.');
      return [];
    }

    try {
      final response = await supabase
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
