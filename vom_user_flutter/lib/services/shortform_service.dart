import 'package:flutter/foundation.dart';

import '../domain/shortform.dart';

/// 숏폼 컨텐츠를 가져오는 서비스
/// MVP 데모용으로는 하드코딩된 목록을 사용하고,
/// 이후 Supabase 연동으로 교체할 수 있도록 설계합니다.
class ShortformService {
  ShortformService._internal();
  static final ShortformService instance = ShortformService._internal();

  /// 데모용 하드코딩 데이터
  /// 실제 환경에서는 Supabase `card_contents` 등을 조회하도록 교체 예정
  final List<Shortform> _demoShortforms = const [
    Shortform(
      id: 'cook_lunch_01',
      title: '점심 준비하기',
      category: '요리',
      videoUrl: 'https://example.com/videos/cook_lunch_01.mp4',
      nfcTagCode: 'nfc_cook_lunch_01',
    ),
    Shortform(
      id: 'bath_01',
      title: '안전하게 목욕하기',
      category: '목욕',
      videoUrl: 'https://example.com/videos/bath_01.mp4',
      nfcTagCode: 'nfc_bath_01',
    ),
    Shortform(
      id: 'play_toys_01',
      title: '장난감 정리 놀이',
      category: '놀이',
      videoUrl: 'https://example.com/videos/play_toys_01.mp4',
      nfcTagCode: 'nfc_play_toys_01',
    ),
  ];

  /// ID로 숏폼 하나 가져오기 (푸시 알림 등에서 사용)
  Future<Shortform?> fetchById(String id) async {
    try {
      // TODO: 이후 Supabase 연동 시 이 부분을 네트워크 호출로 교체
      return _demoShortforms.firstWhere(
        (s) => s.id == id,
        orElse: () => throw StateError('not_found'),
      );
    } catch (e) {
      debugPrint('❌ ShortformService.fetchById error: $e');
      return null;
    }
  }

  /// NFC 태그 코드로 숏폼 하나 가져오기
  Future<Shortform?> fetchByTagCode(String tagCode) async {
    try {
      // TODO: 이후 Supabase `nfc_card_mappings` 와 join 해서 조회
      return _demoShortforms.firstWhere(
        (s) => s.nfcTagCode == tagCode,
        orElse: () => throw StateError('not_found'),
      );
    } catch (e) {
      debugPrint('❌ ShortformService.fetchByTagCode error: $e');
      return null;
    }
  }

  /// 데모용: 오늘의 추천 숏폼 목록
  Future<List<Shortform>> fetchTodayRecommendations() async {
    // 현재는 전체 데모 목록을 그대로 반환
    return _demoShortforms;
  }
}

