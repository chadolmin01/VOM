import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Android 백그라운드 NFC Intent 처리 서비스
class NfcIntentService {
  static const _channel = MethodChannel('com.vom.vom_user/nfc');
  static Function(String tagId)? _onTagDiscovered;

  /// NFC 태그 감지 리스너 등록
  static void setOnTagDiscovered(Function(String tagId) callback) {
    _onTagDiscovered = callback;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// 리스너 해제
  static void dispose() {
    _onTagDiscovered = null;
    _channel.setMethodCallHandler(null);
  }

  /// Native에서 호출되는 메서드 핸들러
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNfcTagDiscovered':
        final tagId = call.arguments as String?;
        if (tagId != null && _onTagDiscovered != null) {
          debugPrint('🏷️ Background NFC detected: $tagId');
          _onTagDiscovered!(tagId);
        }
        break;
      default:
        debugPrint('Unknown method: ${call.method}');
    }
  }
}
