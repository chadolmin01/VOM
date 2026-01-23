import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/models/mission.dart';

/// 미션 캐싱 서비스
/// 네트워크 불안정 환경에서도 마지막으로 받은 미션의 콘텐츠를 재생 가능하도록 함
class MissionCacheService {
  static final MissionCacheService _instance = MissionCacheService._internal();
  factory MissionCacheService() => _instance;
  MissionCacheService._internal();

  static const String _cacheDirName = 'mission_cache';
  static const int _cacheExpiryDays = 7; // 캐시 만료 기간 (일)

  /// 캐시 디렉토리 경로 가져오기
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// 미션 콘텐츠 캐싱
  Future<void> cacheMission(Mission mission) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/${mission.id}.json');

      final cacheData = {
        'mission': mission.toJson(),
        'cached_at': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(cacheData));
      debugPrint('✅ Mission cached: ${mission.id}');
    } catch (e) {
      debugPrint('❌ Failed to cache mission: $e');
    }
  }

  /// 캐시된 미션 조회
  Future<Mission?> getCachedMission(String missionId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final file = File('${cacheDir.path}/$missionId.json');

      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final cacheData = jsonDecode(content) as Map<String, dynamic>;

      // 캐시 만료 확인
      final cachedAt = DateTime.parse(cacheData['cached_at'] as String);
      final expiryDate = cachedAt.add(Duration(days: _cacheExpiryDays));
      if (DateTime.now().isAfter(expiryDate)) {
        debugPrint('⚠️ Cache expired for mission: $missionId');
        await file.delete(); // 만료된 캐시 삭제
        return null;
      }

      final missionJson = cacheData['mission'] as Map<String, dynamic>;
      final mission = Mission.fromJson(missionJson);
      debugPrint('✅ Mission loaded from cache: $missionId');
      return mission;
    } catch (e) {
      debugPrint('❌ Failed to load cached mission: $e');
      return null;
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('✅ Cache cleared');
      }
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }

  /// 만료된 캐시 정리
  Future<void> cleanExpiredCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return;

      final files = cacheDir.listSync();
      final now = DateTime.now();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final cacheData = jsonDecode(content) as Map<String, dynamic>;
            final cachedAt = DateTime.parse(cacheData['cached_at'] as String);
            final expiryDate = cachedAt.add(Duration(days: _cacheExpiryDays));

            if (now.isAfter(expiryDate)) {
              await file.delete();
              debugPrint('🗑️ Expired cache deleted: ${file.path}');
            }
          } catch (e) {
            // 파싱 실패한 파일 삭제
            await file.delete();
            debugPrint('🗑️ Invalid cache deleted: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to clean expired cache: $e');
    }
  }
}
