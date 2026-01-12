# Gemini API 설정 가이드

## Gemini API 키 발급 방법

### 1단계: Google AI Studio 접속
1. 브라우저에서 **https://aistudio.google.com/app/apikey** 접속
2. Google 계정으로 로그인

### 2단계: API 키 생성
1. **"Create API key"** 또는 **"API 키 만들기"** 버튼 클릭
2. 프로젝트 선택:
   - 기존 프로젝트가 있으면 선택
   - 없으면 **"Create API key in new project"** 선택
3. API 키가 생성됨 (예: `AIzaSy...` 형식)
4. **복사(Copy)** 버튼 클릭해서 API 키 복사

### 3단계: 앱에 API 키 입력
1. 파일 열기: `lib/services/ai_chat_service.dart`
2. 6번째 줄 찾기:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY';
   ```
3. 복사한 API 키로 교체:
   ```dart
   static const String _apiKey = 'AIzaSyDfG...여기에_복사한_키';
   ```
4. 파일 저장

### 4단계: 패키지 설치
터미널에서 실행:
```bash
cd vom_user_flutter
flutter pub get
```

## 완료!

이제 앱을 실행하면 Gemini AI와 대화할 수 있습니다.

## Gemini API 무료 한도

| 항목 | 무료 한도 |
|------|-----------|
| **요청 수** | 1,500 requests/day |
| **Rate Limit** | 15 RPM (분당 15회) |
| **모델** | Gemini 1.5 Flash |
| **토큰** | 150만 토큰/분 |

**해커톤에 충분합니다!** 하루 종일 테스트해도 넉넉합니다.

## API 키 보안 (중요)

### ⚠️ GitHub에 올리기 전에

API 키가 포함된 파일을 GitHub에 올리면 **누구나 사용 가능**합니다.

#### 해결 방법 1: .gitignore에 추가
`.gitignore` 파일에 추가:
```
# API 키가 있는 파일 제외
lib/services/ai_chat_service.dart
```

#### 해결 방법 2: 환경 변수 사용 (권장)
나중에 배포할 때는 `.env` 파일로 관리하세요.

## 문제 해결

### "API key not valid" 오류
- API 키를 다시 확인하세요
- 따옴표 안에 전체 키가 들어갔는지 확인
- 공백이나 줄바꿈이 없는지 확인

### "Quota exceeded" 오류
- 하루 1,500회 제한을 초과함
- 내일 다시 시도하거나 새 프로젝트 생성

### 응답이 안 와요
- 인터넷 연결 확인
- API 키가 올바른지 확인
- 오프라인 모드는 키워드 기반으로 작동

## Gemini vs OpenAI 비교

| 항목 | Gemini (현재) | OpenAI |
|------|---------------|--------|
| 무료 한도 | 1,500/day (영구) | $5 크레딧 (소진 후 유료) |
| 한국어 품질 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 응답 속도 | 0.5-1초 | 1-3초 |
| 설정 난이도 | 쉬움 | 중간 |

## 오프라인 모드

API 키가 없어도 앱은 작동합니다:
- 키워드 기반 응답
- 응급 상황 안내
- 일반 육아 질문

예시:
```
사용자: "열이 많아요"
앱: "아이에게 열이 높으면 옷을 가볍게 입히고..."
```

## API 키 링크 정리

- **API 키 발급**: https://aistudio.google.com/app/apikey
- **Gemini 문서**: https://ai.google.dev/docs
- **요금 정책**: https://ai.google.dev/pricing
