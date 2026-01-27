import '../../../data/services/phone_service.dart';

/// 온보딩에서 사용하는 전화번호 관련 로직
class PhoneLogic {
  final PhoneService _phoneService = PhoneService();

  /// USIM에서 전화번호 자동 읽기
  /// 
  /// Returns: 읽은 전화번호 (010-1234-5678 형식) 또는 null
  Future<String?> readPhoneFromSim() async {
    try {
      final phoneNumber = await _phoneService.readPhoneNumber();
      return phoneNumber;
    } catch (e) {
      return null;
    }
  }

  /// 전화번호 형식 검증
  bool isValidPhoneNumber(String phone) {
    return _phoneService.isValidPhoneNumber(phone);
  }

  /// 전화번호 정리 (숫자만 추출)
  String cleanPhoneNumber(String phone) {
    return _phoneService.cleanPhoneNumber(phone);
  }

  /// 전화번호 포맷팅 (010-1234-5678 형식)
  String formatPhoneNumber(String phone) {
    final cleaned = cleanPhoneNumber(phone);
    if (cleaned.length == 11 && cleaned.startsWith('010')) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10 && cleaned.startsWith('10')) {
      return '0${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }
}
