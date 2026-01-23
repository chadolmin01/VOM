import 'package:flutter/foundation.dart';

/// 학습 세션 추적 클래스
/// 태그 시각, 재시도 횟수, 반응 속도, 위기 지수를 추적
class LearningSessionTracker {
  DateTime? _taggedAt;
  int _retryCount = 0;
  DateTime? _completedAt;
  List<String> _riskKeywords = [];

  /// 태그 시각 기록
  void recordTagged() {
    _taggedAt = DateTime.now();
    _retryCount = 0; // 새 태그 시 재시도 횟수 초기화
    debugPrint('📌 LearningSessionTracker: Tagged at ${_taggedAt}');
  }

  /// 재태깅/재스캔 횟수 증가
  void incrementRetry() {
    _retryCount++;
    debugPrint('🔄 LearningSessionTracker: Retry count = $_retryCount');
  }

  /// 완료 시각 기록
  void recordCompleted() {
    _completedAt = DateTime.now();
    debugPrint('✅ LearningSessionTracker: Completed at ${_completedAt}');
  }

  /// 위험 키워드 추가
  void addRiskKeywords(List<String> keywords) {
    _riskKeywords.addAll(keywords);
    debugPrint('⚠️ LearningSessionTracker: Risk keywords = $_riskKeywords');
  }

  /// 반응 속도 계산 (초 단위)
  /// 태그 시각부터 완료 시각까지의 시간
  int? get reactionTime {
    if (_taggedAt == null || _completedAt == null) {
      return null;
    }
    final duration = _completedAt!.difference(_taggedAt!);
    return duration.inSeconds;
  }

  /// 재시도 횟수
  int get retryCount => _retryCount;

  /// 태그 시각
  DateTime? get taggedAt => _taggedAt;

  /// 완료 시각
  DateTime? get completedAt => _completedAt;

  /// 위험 키워드 목록
  List<String> get riskKeywords => List.unmodifiable(_riskKeywords);

  /// 위기 지수 계산 (0.00~100.00)
  /// 
  /// 계산 공식:
  /// - 위험 키워드: 키워드당 20점 (최대 40점)
  /// - 반응 속도: 5분 이상이면 30점, 10분 이상이면 50점
  /// - 재시도 횟수: 3회 이상이면 20점, 5회 이상이면 40점
  /// - 최대 100점
  double? calculateRiskScore() {
    double score = 0.0;

    // 위험 키워드 점수 (키워드당 20점, 최대 40점)
    final keywordScore = (_riskKeywords.length * 20).clamp(0, 40);
    score += keywordScore;

    // 반응 속도 점수
    final reaction = reactionTime;
    if (reaction != null) {
      if (reaction >= 600) {
        // 10분 이상
        score += 50;
      } else if (reaction >= 300) {
        // 5분 이상
        score += 30;
      } else if (reaction >= 180) {
        // 3분 이상
        score += 15;
      }
    }

    // 재시도 횟수 점수
    if (_retryCount >= 5) {
      score += 40;
    } else if (_retryCount >= 3) {
      score += 20;
    } else if (_retryCount >= 1) {
      score += 10;
    }

    // 최대 100점으로 제한
    final finalScore = score.clamp(0.0, 100.0);
    debugPrint('📊 LearningSessionTracker: Risk score = $finalScore (keywords: $keywordScore, reaction: ${reaction != null ? (reaction >= 600 ? 50 : reaction >= 300 ? 30 : reaction >= 180 ? 15 : 0) : 0}, retries: ${_retryCount >= 5 ? 40 : _retryCount >= 3 ? 20 : _retryCount >= 1 ? 10 : 0})');
    return finalScore;
  }

  /// 세션 데이터를 Map으로 변환 (Supabase 저장용)
  Map<String, dynamic> toJson() {
    return {
      'tagged_at': _taggedAt?.toIso8601String(),
      'completed_at': _completedAt?.toIso8601String(),
      'reaction_time': reactionTime,
      'retry_count': _retryCount,
      'risk_keywords': _riskKeywords.isNotEmpty ? _riskKeywords : null,
      'risk_score': calculateRiskScore(),
    };
  }

  /// 세션 초기화
  void reset() {
    _taggedAt = null;
    _retryCount = 0;
    _completedAt = null;
    _riskKeywords.clear();
    debugPrint('🔄 LearningSessionTracker: Reset');
  }
}
