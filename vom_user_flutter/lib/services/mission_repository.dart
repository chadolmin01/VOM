import 'package:flutter/foundation.dart';

import '../constants/nfc_contents.dart';
import '../domain/models/mission.dart';
import 'supabase_service.dart';
import 'mission_cache_service.dart';

/// NFC / QR / 딥링크 mission_id 를 받아 카드 콘텐츠를 찾아오는 도메인 레이어
class MissionRepository {
  final SupabaseService _supabase;
  final MissionCacheService _cache = MissionCacheService();

  MissionRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// 딥링크에서 넘어온 mission_id 로 콘텐츠 조회 (캐싱 지원)
  Future<CardContent?> loadByMissionId(String missionId) async {
    // 1) 네트워크에서 조회 시도
    try {
      final data = await _supabase.getContentById(missionId);
      if (data != null) {
        debugPrint('✅ MissionRepository.loadByMissionId - from DB: $missionId');
        final mission = Mission.fromJson(data);
        
        // 성공 시 캐싱
        await _cache.cacheMission(mission);
        
        // CardContent로 변환 (기존 호환성 유지)
        return CardContent(
          id: mission.id,
          name: mission.name,
          icon: mission.icon,
          scripts: mission.scripts,
          audioUrl: mission.audioUrl,
          videoUrl: mission.videoUrl,
          quizQuestion: mission.quizQuestion,
          quizOptions: mission.quizOptions,
          quizCorrectIndex: mission.quizCorrectIndex,
        );
      }
    } catch (e) {
      debugPrint('❌ loadByMissionId DB error: $e');
      // 네트워크 실패 시 캐시 조회
      final cached = await _cache.getCachedMission(missionId);
      if (cached != null) {
        debugPrint('✅ MissionRepository.loadByMissionId - from cache: $missionId');
        return CardContent(
          id: cached.id,
          name: cached.name,
          icon: cached.icon,
          scripts: cached.scripts,
          audioUrl: cached.audioUrl,
          videoUrl: cached.videoUrl,
          quizQuestion: cached.quizQuestion,
          quizOptions: cached.quizOptions,
          quizCorrectIndex: cached.quizCorrectIndex,
        );
      }
    }

    // 2) DB에 없으면 폴백 콘텐츠에서 찾기
    final fallback = getFallbackContentById(missionId);
    if (fallback != null) {
      debugPrint(
          '✅ MissionRepository.loadByMissionId - from fallback: $missionId');
    } else {
      debugPrint(
          '❌ MissionRepository.loadByMissionId - not found: $missionId');
    }
    return fallback;
  }

  /// NFC UID 기반 콘텐츠 조회 (캐싱 지원)
  Future<CardContent?> loadByNfcTagId(String tagId) async {
    CardContent? matched;

    // 1) 매핑 + 콘텐츠 join 으로 직접 조회
    try {
      final data = await _supabase.getContentByNfcTagId(tagId);
      if (data != null) {
        final mission = Mission.fromJson(data);
        
        // 성공 시 캐싱
        await _cache.cacheMission(mission);
        
        matched = CardContent(
          id: mission.id,
          name: mission.name,
          icon: mission.icon,
          scripts: mission.scripts,
          audioUrl: mission.audioUrl,
          videoUrl: mission.videoUrl,
          quizQuestion: mission.quizQuestion,
          quizOptions: mission.quizOptions,
          quizCorrectIndex: mission.quizCorrectIndex,
        );
        debugPrint('✅ MissionRepository.loadByNfcTagId - content join: $tagId');
        return matched;
      }
    } catch (e) {
      debugPrint('❌ loadByNfcTagId join error: $e');
    }

    // 2) 매핑 테이블에서 card_id 가져온 뒤, 캐시 또는 폴백 콘텐츠에서 찾기
    try {
      final mapping = await _supabase.getCardMappingByNfcTagId(tagId);
      final cardId = mapping?['card_id'] as String?;
      if (cardId != null) {
        // 먼저 캐시 확인
        final cached = await _cache.getCachedMission(cardId);
        if (cached != null) {
          debugPrint('✅ MissionRepository.loadByNfcTagId - from cache by cardId: $cardId');
          return CardContent(
            id: cached.id,
            name: cached.name,
            icon: cached.icon,
            scripts: cached.scripts,
            audioUrl: cached.audioUrl,
            videoUrl: cached.videoUrl,
            quizQuestion: cached.quizQuestion,
            quizOptions: cached.quizOptions,
            quizCorrectIndex: cached.quizCorrectIndex,
          );
        }
        
        // 캐시에 없으면 폴백 콘텐츠에서 찾기
        matched = getFallbackContentById(cardId);
        if (matched != null) {
          debugPrint(
              '✅ MissionRepository.loadByNfcTagId - from fallback by cardId: $cardId');
          return matched;
        }
      }
    } catch (e) {
      debugPrint('❌ loadByNfcTagId mapping error: $e');
    }

    debugPrint('❌ MissionRepository.loadByNfcTagId - not found: $tagId');
    return null;
  }

  /// QR 코드 기반 콘텐츠 조회 (캐싱 지원)
  Future<CardContent?> loadByQrCode(String qrCode) async {
    CardContent? matched;

    // 1) 매핑 + 콘텐츠 join
    try {
      final data = await _supabase.getContentByQrCode(qrCode);
      if (data != null) {
        final mission = Mission.fromJson(data);
        
        // 성공 시 캐싱
        await _cache.cacheMission(mission);
        
        matched = CardContent(
          id: mission.id,
          name: mission.name,
          icon: mission.icon,
          scripts: mission.scripts,
          audioUrl: mission.audioUrl,
          videoUrl: mission.videoUrl,
          quizQuestion: mission.quizQuestion,
          quizOptions: mission.quizOptions,
          quizCorrectIndex: mission.quizCorrectIndex,
        );
        debugPrint('✅ MissionRepository.loadByQrCode - content join');
        return matched;
      }
    } catch (e) {
      debugPrint('❌ loadByQrCode join error: $e');
    }

    // 2) 매핑에서 card_id 가져온 뒤, 캐시 또는 폴백 콘텐츠에서 찾기
    try {
      final mapping = await _supabase.getCardMappingByQrCode(qrCode);
      final cardId = mapping?['card_id'] as String?;
      if (cardId != null) {
        // 먼저 캐시 확인
        final cached = await _cache.getCachedMission(cardId);
        if (cached != null) {
          debugPrint('✅ MissionRepository.loadByQrCode - from cache by cardId: $cardId');
          return CardContent(
            id: cached.id,
            name: cached.name,
            icon: cached.icon,
            scripts: cached.scripts,
            audioUrl: cached.audioUrl,
            videoUrl: cached.videoUrl,
            quizQuestion: cached.quizQuestion,
            quizOptions: cached.quizOptions,
            quizCorrectIndex: cached.quizCorrectIndex,
          );
        }
        
        // 캐시에 없으면 폴백 콘텐츠에서 찾기
        matched = getFallbackContentById(cardId);
        if (matched != null) {
          debugPrint(
              '✅ MissionRepository.loadByQrCode - from fallback by cardId: $cardId');
          return matched;
        }
      }
    } catch (e) {
      debugPrint('❌ loadByQrCode mapping error: $e');
    }

    debugPrint('❌ MissionRepository.loadByQrCode - not found');
    return null;
  }
}

