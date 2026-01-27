/// 온보딩에서 사용하는 이름 관련 로직
class NameLogic {
  /// 이름 유효성 검증
  /// 
  /// - 최소 2자 이상
  /// - 최대 10자 이하
  /// - 한글, 영문, 숫자만 허용
  bool isValidName(String name) {
    if (name.isEmpty) return false;
    if (name.length < 2) return false;
    if (name.length > 10) return false;

    // 한글, 영문, 숫자만 허용
    final regex = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    return regex.hasMatch(name);
  }

  /// 이름 정리 (앞뒤 공백 제거)
  String cleanName(String name) {
    return name.trim();
  }

  /// 이름 포맷팅 (첫 글자만 대문자, 나머지 소문자 - 영문인 경우)
  String formatName(String name) {
    final cleaned = cleanName(name);
    if (cleaned.isEmpty) return cleaned;

    // 한글이 포함되어 있으면 그대로 반환
    if (RegExp(r'[가-힣]').hasMatch(cleaned)) {
      return cleaned;
    }

    // 영문인 경우 첫 글자만 대문자
    if (cleaned.length == 1) {
      return cleaned.toUpperCase();
    }
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }
}
