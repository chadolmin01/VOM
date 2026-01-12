// NFC 카드 콘텐츠 모델 (v2 - UID 매핑 방식)
// 콘텐츠는 DB(Supabase)에서 관리, 이 파일은 모델과 유틸리티만 포함

/// 카드 콘텐츠 모델
class CardContent {
  final String id;
  final String name;
  final String icon;
  final List<String> scripts;
  final String? audioUrl;
  final String? videoUrl;
  final String? quizQuestion;
  final List<String>? quizOptions;
  final int quizCorrectIndex;

  const CardContent({
    required this.id,
    required this.name,
    required this.icon,
    required this.scripts,
    this.audioUrl,
    this.videoUrl,
    this.quizQuestion,
    this.quizOptions,
    this.quizCorrectIndex = 0,
  });

  /// Supabase JSON에서 생성
  factory CardContent.fromJson(Map<String, dynamic> json) {
    return CardContent(
      id: json['id'] ?? '',
      name: json['name'] ?? '알 수 없음',
      icon: json['icon'] ?? '📦',
      scripts: _parseStringList(json['scripts']),
      audioUrl: json['audio_url'],
      videoUrl: json['video_url'],
      quizQuestion: json['quiz_question'],
      quizOptions: _parseStringList(json['quiz_options']),
      quizCorrectIndex: json['quiz_correct_index'] ?? 0,
    );
  }

  /// 퀴즈가 있는지 확인
  bool get hasQuiz => quizQuestion != null && quizOptions != null && quizOptions!.isNotEmpty;

  /// PostgreSQL 배열 또는 List를 List<String>으로 변환
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // PostgreSQL 배열 형식 "{a,b,c}" 파싱
      if (value.startsWith('{') && value.endsWith('}')) {
        return value.substring(1, value.length - 1).split(',').map((e) => e.trim()).toList();
      }
      return [value];
    }
    return [];
  }
}

// ============================================================
// 위험 키워드 감지 (로컬에서 처리)
// ============================================================

/// 위험 키워드 목록
const List<String> riskKeywords = [
  '때리',
  '맞',
  '죽',
  '피',
  '아파',
  '무서',
  '싫어',
  '안돼',
  '도와',
  '살려',
];

/// 위험 키워드 감지 함수
List<String> detectRiskKeywords(String text) {
  List<String> detected = [];
  for (String keyword in riskKeywords) {
    if (text.contains(keyword)) {
      detected.add(keyword);
    }
  }
  return detected;
}

// ============================================================
// 오프라인 폴백용 기본 콘텐츠 (DB 연결 실패 시)
// ============================================================

const List<CardContent> fallbackContents = [
  CardContent(
    id: '1',
    name: '체온계',
    icon: '🌡️',
    scripts: [
      '체온계 사용법을 알려드릴게요.',
      '먼저 체온계 전원 버튼을 눌러주세요.',
      '삐 소리가 나면 아이 겨드랑이에 넣어주세요.',
      '다시 삐 소리가 날 때까지 기다려주세요.',
      '37.5도가 넘으면 열이 있는 거예요.',
    ],
    quizQuestion: '열이 있다고 판단하는 체온은?',
    quizOptions: ['36.5도', '37.5도', '38.5도'],
    quizCorrectIndex: 1,
  ),
  CardContent(
    id: '2',
    name: '약병',
    icon: '💊',
    scripts: [
      '약 먹이는 방법을 알려드릴게요.',
      '먼저 약병을 흔들어 주세요.',
      '스포이드로 정해진 양만큼 빨아주세요.',
      '아이 입 안쪽 볼에 천천히 넣어주세요.',
      '다 먹으면 물을 조금 먹여주세요.',
    ],
    quizQuestion: '약을 먹일 때 어디에 넣어야 할까요?',
    quizOptions: ['혀 위에', '입 안쪽 볼에', '목구멍에'],
    quizCorrectIndex: 1,
  ),
  CardContent(
    id: '3',
    name: '치약',
    icon: '🦷',
    scripts: [
      '아이 양치하는 방법이에요.',
      '칫솔에 콩알만큼 치약을 짜주세요.',
      '위에서 아래로 쓸어내려 주세요.',
      '바깥쪽, 안쪽, 씹는 면을 닦아주세요.',
      '물로 입을 헹궈주세요.',
    ],
    quizQuestion: '치약은 얼마나 짜야 할까요?',
    quizOptions: ['콩알만큼', '칫솔 가득', '손가락 한마디'],
    quizCorrectIndex: 0,
  ),
];

/// ID로 폴백 콘텐츠 찾기
CardContent? getFallbackContentById(String id) {
  try {
    return fallbackContents.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
