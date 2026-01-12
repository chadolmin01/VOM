import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// AI 음성 챗봇 서비스 (Gemini API)
class AiChatService {
  static const String _apiKey = 'AIzaSyBT1psDP7a2AqYPTzWW_tAyrsbKAbvBRNY';

  GenerativeModel? _model;
  ChatSession? _chat;

  /// 현재 학습 중인 카드 컨텍스트
  String? _currentCardName;
  String? _currentCardContext;

  /// API 키가 설정되었는지 확인
  bool get isConfigured => _apiKey != 'YOUR_GEMINI_API_KEY';

  /// 학습 컨텍스트 설정 (카드 학습 시작 시 호출)
  void setLearningContext({
    required String cardName,
    required List<String> scripts,
    String? quizQuestion,
  }) {
    _currentCardName = cardName;
    _currentCardContext = '''
현재 사용자는 "$cardName" 사용법을 배우고 있습니다.
학습 내용:
${scripts.map((s) => '- $s').join('\n')}
${quizQuestion != null ? '\n퀴즈: $quizQuestion' : ''}
''';
    _initModel();
  }

  /// 컨텍스트 초기화
  void clearContext() {
    _currentCardName = null;
    _currentCardContext = null;
    _chat = null;
  }

  /// Gemini 모델 초기화
  void _initModel() {
    if (!isConfigured) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 200,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        ],
      );

      // 채팅 세션 시작
      _chat = _model!.startChat(history: [
        Content.text(_systemPrompt),
      ]);
    } catch (e) {
      debugPrint('Gemini model init error: $e');
    }
  }

  /// 시스템 프롬프트 (제한된 역할 정의)
  String get _systemPrompt => '''
당신은 "V.O.M(보이스 오브 마더)" 앱의 친절한 육아 도우미입니다.
글을 읽지 못하는 엄마들을 위해 음성으로 도움을 드립니다.

[역할]
- 아이 돌봄에 필요한 물건 사용법을 쉽게 설명합니다
- 육아 관련 간단한 질문에 답변합니다
- 응급 상황에는 119에 전화하도록 안내합니다

[제한사항]
- 육아/건강/아이돌봄 외의 주제는 정중히 거절하세요
- 의료 진단이나 처방은 하지 마세요. 병원 방문을 권유하세요
- 답변은 2-3문장으로 짧고 명확하게 하세요
- 존댓말을 사용하고 따뜻한 톤으로 말하세요

${_currentCardContext ?? ''}

이제 사용자의 질문에 답변해주세요.
''';

  /// AI에게 질문하고 답변 받기
  Future<String> chat(String userMessage) async {
    if (!isConfigured || _chat == null) {
      return _getOfflineResponse(userMessage);
    }

    try {
      final response = await _chat!.sendMessage(Content.text(userMessage));
      final text = response.text?.trim() ?? '';

      if (text.isEmpty) {
        return _getOfflineResponse(userMessage);
      }

      return text;
    } catch (e) {
      debugPrint('Gemini chat error: $e');
      return _getOfflineResponse(userMessage);
    }
  }

  /// 오프라인/에러 시 기본 응답 (키워드 기반)
  String _getOfflineResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // 현재 학습 중인 카드 관련 질문
    if (_currentCardName != null) {
      if (message.contains('어떻게') || message.contains('방법') || message.contains('사용')) {
        return '$_currentCardName 사용법을 다시 들려드릴까요? 화면의 다시 듣기 버튼을 눌러주세요.';
      }
      if (message.contains('어려') || message.contains('모르') || message.contains('이해')) {
        return '천천히 다시 설명해 드릴게요. 어려운 부분이 있으면 말씀해 주세요.';
      }
    }

    // 응급 상황
    if (message.contains('열') && (message.contains('높') || message.contains('많'))) {
      return '아이에게 열이 높으면 옷을 가볍게 입히고, 38.5도가 넘으면 해열제를 주세요. 39도 이상이면 병원에 가세요.';
    }
    if (message.contains('다치') || message.contains('피') || message.contains('아파')) {
      return '아이가 다쳤다면 먼저 상처 부위를 깨끗이 씻어주세요. 심하면 119에 전화하세요.';
    }
    if (message.contains('숨') || message.contains('기침') || message.contains('막')) {
      return '숨을 못 쉬면 즉시 119에 전화하세요! 기침이 심하면 등을 두드려 주세요.';
    }

    // 일반 육아 질문
    if (message.contains('약') || message.contains('먹')) {
      return '약은 정해진 시간에 정해진 양만 먹이세요. 약병에 적힌 대로 따라하시면 돼요.';
    }
    if (message.contains('밥') || message.contains('이유식')) {
      return '이유식은 미지근하게 데워서 한 숟가락씩 천천히 먹이세요.';
    }
    if (message.contains('울') || message.contains('운')) {
      return '아이가 울면 배가 고프거나, 기저귀가 젖었거나, 안아달라는 신호예요. 하나씩 확인해 보세요.';
    }
    if (message.contains('잠') || message.contains('자')) {
      return '아이가 잠들기 전에 조용한 환경을 만들어 주시고, 등을 토닥여 주세요.';
    }

    // 인사
    if (message.contains('안녕') || message.contains('처음')) {
      return '안녕하세요! 육아에 대해 궁금한 점을 물어봐 주세요.';
    }

    // 주제 벗어남
    if (message.contains('날씨') || message.contains('뉴스') || message.contains('게임')) {
      return '죄송해요, 저는 육아 도우미라서 그 질문에는 답하기 어려워요. 아이 돌봄에 대해 물어봐 주세요!';
    }

    // 기본 응답
    return _currentCardName != null
        ? '무엇이 궁금하신가요? $_currentCardName 사용법에 대해 더 설명해 드릴까요?'
        : '육아에 대해 궁금한 점을 말씀해 주세요. 체온계, 기저귀, 분유 등 어떤 것이든 물어보세요!';
  }
}
