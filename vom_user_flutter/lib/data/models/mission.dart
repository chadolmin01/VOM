/// 미션(카드 콘텐츠) 모델 (Supabase 스키마와 1:1 매핑)
/// CardContent를 대체하는 공통 모델
class Mission {
  final String id;
  final String name;
  final String icon;
  final List<String> scripts;
  final String? audioUrl;
  final String? videoUrl;
  final String? quizQuestion;
  final List<String>? quizOptions;
  final int quizCorrectIndex;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Mission({
    required this.id,
    required this.name,
    required this.icon,
    required this.scripts,
    this.audioUrl,
    this.videoUrl,
    this.quizQuestion,
    this.quizOptions,
    this.quizCorrectIndex = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Supabase JSON에서 생성
  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '알 수 없음',
      icon: json['icon']?.toString() ?? '📦',
      scripts: _parseStringList(json['scripts']),
      audioUrl: json['audio_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      quizQuestion: json['quiz_question']?.toString(),
      quizOptions: _parseStringList(json['quiz_options']),
      quizCorrectIndex: json['quiz_correct_index'] != null
          ? (json['quiz_correct_index'] is int
              ? json['quiz_correct_index'] as int
              : int.tryParse(json['quiz_correct_index'].toString()) ?? 0)
          : 0,
      isActive: json['is_active'] != null
          ? (json['is_active'] is bool
              ? json['is_active'] as bool
              : json['is_active'].toString().toLowerCase() == 'true')
          : true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  /// Supabase에 저장할 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'scripts': scripts,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (quizQuestion != null) 'quiz_question': quizQuestion,
      if (quizOptions != null) 'quiz_options': quizOptions,
      'quiz_correct_index': quizCorrectIndex,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// 퀴즈가 있는지 확인
  bool get hasQuiz =>
      quizQuestion != null &&
      quizOptions != null &&
      quizOptions!.isNotEmpty;

  /// PostgreSQL 배열 또는 List를 List<String>으로 변환
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // PostgreSQL 배열 형식 "{a,b,c}" 파싱
      if (value.startsWith('{') && value.endsWith('}')) {
        return value
            .substring(1, value.length - 1)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
      return [value];
    }
    return [];
  }
}
