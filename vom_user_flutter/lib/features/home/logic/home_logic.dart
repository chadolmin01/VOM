import '../../../data/services/onboarding_backend.dart';
import '../../../data/services/mission_repository.dart';
import '../../../core/constants/nfc_contents.dart';

/// 홈 화면에서 사용하는 비즈니스 로직
class HomeLogic {
  final MissionRepository _missionRepository = MissionRepository();

  /// 사용자 프로필 로드
  Future<Map<String, dynamic>?> loadUserProfile() async {
    final profile = await onboardingBackend.loadProfile();
    if (profile == null) return null;

    return {
      'name': profile.name,
      'phone': profile.phone,
      'interests': profile.interests,
      'step': profile.step,
    };
  }

  /// 오늘의 할 일 계산 (임시 - 추후 서버 연동)
  /// 
  /// Returns: 오늘 완료해야 할 학습 카드 목록
  Future<List<CardContent>> getTodayTasks() async {
    // TODO: 서버에서 오늘의 할 일 가져오기
    // 현재는 폴백 콘텐츠에서 첫 3개 반환
    return fallbackContents.take(3).toList();
  }

  /// 출석 도장 개수 계산 (임시 - 추후 서버 연동)
  /// 
  /// Returns: 이번 주 출석 도장 개수 (0-7)
  Future<int> getAttendanceCount() async {
    // TODO: 서버에서 출석 데이터 가져오기
    // 현재는 임시로 0 반환
    return 0;
  }

  /// NFC 태그로 학습 카드 찾기
  Future<CardContent?> findCardByNfcTag(String tagId) async {
    return await _missionRepository.loadByNfcTagId(tagId);
  }

  /// QR 코드로 학습 카드 찾기
  Future<CardContent?> findCardByQrCode(String qrCode) async {
    return await _missionRepository.loadByQrCode(qrCode);
  }
}
