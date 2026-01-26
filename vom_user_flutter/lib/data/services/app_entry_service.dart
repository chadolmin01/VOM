import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 앱 진입 경로를 판단하는 서비스
///
/// - **입구 (태그 + 알람)**: NFC 태그로 앱이 열릴 때 → 바로 학습 화면으로
/// - **사이드 입구 (직접 실행)**: 앱 아이콘을 눌러서 열 때 → 온보딩 체크 후 홈 화면
class AppEntryService {
  static const _channel = MethodChannel('com.vom.vom_user/nfc');

  /// 앱 시작 시점에 NFC Intent가 있는지 확인
  ///
  /// - NFC 태그로 앱이 열렸으면: tagId 반환 (입구)
  /// - 일반 실행이면: null 반환 (사이드 입구)
  static Future<String?> checkInitialNfcIntent() async {
    try {
      final result = await _channel.invokeMethod<String?>('getInitialNfcTagId');
      if (result != null && result.isNotEmpty) {
        debugPrint('🏷️ [AppEntryService] NFC Intent detected on app start: $result');
        return result;
      }
      debugPrint('📱 [AppEntryService] Normal app launch (no NFC Intent)');
      return null;
    } catch (e) {
      debugPrint('⚠️ [AppEntryService] checkInitialNfcIntent error: $e');
      return null;
    }
  }
}
