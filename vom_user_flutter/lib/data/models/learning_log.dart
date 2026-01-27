/// 학습 로그 모델 (Supabase 스키마와 1:1 매핑)
class LearningLog {
  final String id;
  final String? userId;
  final String deviceId;
  final String? cardId;
  final String cardName;
  final String? cardIcon;
  final String? speechText;
  final bool? quizCorrect;
  final List<String>? riskKeywords;
  final int? reactionTime; // 태그 후 완료까지 걸린 시간 (초 단위)
  final int retryCount; // 재태깅/재스캔 횟수
  final double? riskScore; // 위기 지수 (0.00~100.00)
  final DateTime? taggedAt; // 태그 시각
  final DateTime completedAt; // 완료 시각

  LearningLog({
    required this.id,
    this.userId,
    required this.deviceId,
    this.cardId,
    required this.cardName,
    this.cardIcon,
    this.speechText,
    this.quizCorrect,
    this.riskKeywords,
    this.reactionTime,
    this.retryCount = 0,
    this.riskScore,
    this.taggedAt,
    required this.completedAt,
  });

  /// Supabase JSON에서 생성
  factory LearningLog.fromJson(Map<String, dynamic> json) {
    return LearningLog(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      deviceId: json['device_id']?.toString() ?? '',
      cardId: json['card_id']?.toString(),
      cardName: json['card_name']?.toString() ?? '',
      cardIcon: json['card_icon']?.toString(),
      speechText: json['speech_text']?.toString(),
      quizCorrect: json['quiz_correct'] as bool?,
      riskKeywords: json['risk_keywords'] != null
          ? List<String>.from(json['risk_keywords'])
          : null,
      reactionTime: json['reaction_time'] != null
          ? (json['reaction_time'] is int
              ? json['reaction_time'] as int
              : int.tryParse(json['reaction_time'].toString()))
          : null,
      retryCount: json['retry_count'] != null
          ? (json['retry_count'] is int
              ? json['retry_count'] as int
              : int.tryParse(json['retry_count'].toString()) ?? 0)
          : 0,
      riskScore: json['risk_score'] != null
          ? (json['risk_score'] is double
              ? json['risk_score'] as double
              : double.tryParse(json['risk_score'].toString()))
          : null,
      taggedAt: json['tagged_at'] != null
          ? DateTime.parse(json['tagged_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'].toString())
          : DateTime.now(),
    );
  }

  /// Supabase에 저장할 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'device_id': deviceId,
      if (cardId != null) 'card_id': cardId,
      'card_name': cardName,
      if (cardIcon != null) 'card_icon': cardIcon,
      if (speechText != null) 'speech_text': speechText,
      if (quizCorrect != null) 'quiz_correct': quizCorrect,
      if (riskKeywords != null && riskKeywords!.isNotEmpty)
        'risk_keywords': riskKeywords,
      if (reactionTime != null) 'reaction_time': reactionTime,
      'retry_count': retryCount,
      if (riskScore != null) 'risk_score': riskScore,
      if (taggedAt != null) 'tagged_at': taggedAt!.toIso8601String(),
      'completed_at': completedAt.toIso8601String(),
    };
  }

  /// 위험 키워드가 있는지 확인
  bool get hasRisk => riskKeywords != null && riskKeywords!.isNotEmpty;

  /// 위기 세션인지 확인 (risk_score가 50 이상)
  bool get isRiskSession => riskScore != null && riskScore! >= 50.0;

  /// 반응 속도가 느린지 확인 (reaction_time이 300초 이상 = 5분 이상)
  bool get isSlowReaction =>
      reactionTime != null && reactionTime! >= 300;

  /// 재시도가 많은지 확인 (retry_count가 3 이상)
  bool get hasManyRetries => retryCount >= 3;
}
