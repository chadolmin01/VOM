import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// SIM 카드에서 전화번호를 읽어오는 서비스
class PhoneService {
  static const MethodChannel _channel = MethodChannel('com.vom.vom_user/phone');
  static final PhoneService _instance = PhoneService._internal();
  factory PhoneService() => _instance;
  PhoneService._internal();

  /// 전화번호 읽기 권한 요청
  Future<bool> requestPhonePermission() async {
    try {
      // permission_handler로 먼저 권한 확인
      final status = await Permission.phone.status;
      
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.phone.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // 설정 화면으로 이동
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('전화번호 권한 요청 오류: $e');
      return false;
    }
  }

  /// SIM 카드에서 전화번호 읽기
  /// 
  /// Returns: 읽은 전화번호 (010-1234-5678 형식) 또는 null (읽기 실패 시)
  Future<String?> readPhoneNumber() async {
    try {
      // 권한 확인
      final hasPermission = await requestPhonePermission();
      if (!hasPermission) {
        debugPrint('전화번호 읽기 권한이 없습니다.');
        return null;
      }

      // 네이티브 코드 호출
      final phoneNumber = await _channel.invokeMethod<String>('readPhoneNumber');
      
      if (phoneNumber == null || phoneNumber.isEmpty) {
        debugPrint('전화번호를 읽을 수 없습니다.');
        return null;
      }

      // 한국 전화번호 형식으로 정리
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      
      // 010-1234-5678 형식으로 포맷팅
      if (cleaned.length == 11 && cleaned.startsWith('010')) {
        return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
      } else if (cleaned.length == 10 && cleaned.startsWith('10')) {
        return '0${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
      }

      return phoneNumber;
    } on PlatformException catch (e) {
      debugPrint('전화번호 읽기 오류: ${e.message}');
      if (e.code == 'PERMISSION_DENIED') {
        // 권한이 거부된 경우
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('전화번호 읽기 예외: $e');
      return null;
    }
  }

  /// 전화번호 형식 검증
  bool isValidPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 11 && cleaned.startsWith('010');
  }

  /// 전화번호를 숫자만으로 정리 (01012345678)
  String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
