# V.O.M 배포 가이드

## 배포 완료 항목

### 1. vom-web (Next.js 관리자 대시보드)
- **Vercel 배포 완료**
- **프로덕션 URL**: https://vom-web.vercel.app
- **대체 URL**: https://vom-4jnvdbdjl-leeseongmins-projects-2832c478.vercel.app
- **배포 시간**: 2026-01-12
- **빌드 상태**: ✅ 성공

**기능**:
- 실시간 대시보드 (사용자/학습 통계)
- 사용자 관리
- NFC/QR 카드 관리
- 학습 데이터 모니터링
- 위험 키워드 알림

### 2. vom_user_flutter (사용자/가족용 앱)
- **APK 빌드 중**
- **출력 경로**: `vom_user_flutter/build/app/outputs/flutter-apk/app-release.apk`
- **버전**: 1.0.0+1

**주요 기능**:
- NFC/QR 카드 스캔 (백그라운드 지원)
- 음성 기반 학습 (TTS)
- 단계별 그래픽 애니메이션
- AI 음성 챗봇 (Gemini)
- 학습 기록 저장

### 3. vom_admin_flutter (관리자용 앱)
- **APK 빌드 중**
- **출력 경로**: `vom_admin_flutter/build/app/outputs/flutter-apk/app-release.apk`
- **버전**: 1.0.0+1

**주요 기능**:
- 실시간 모니터링
- 위험 상황 알림
- 사용자 관리
- 학습 데이터 분석

## 빌드 정보

### 웹 (vom-web)
```bash
cd vom-web
npm run build
vercel --prod
```

### Flutter 앱
```bash
# User App
cd vom_user_flutter
flutter clean
flutter pub get
flutter build apk --release

# Admin App
cd vom_admin_flutter
flutter clean
flutter pub get
flutter build apk --release
```

## 기술 스택

### vom-web
- Next.js 14.2.35
- React 18
- Tailwind CSS
- Supabase Client

### vom_user_flutter
- Flutter 3.x
- Packages:
  - google_generative_ai (Gemini AI)
  - flutter_nfc_kit (NFC)
  - mobile_scanner (QR)
  - speech_to_text (음성 인식)
  - flutter_tts (음성 출력)
  - supabase_flutter

### vom_admin_flutter
- Flutter 3.x
- Supabase 실시간 구독
- 차트 라이브러리

## 환경 변수

### vom-web (.env.local)
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Flutter 앱
Gemini API 키: `lib/services/ai_chat_service.dart`
```dart
static const String _apiKey = 'AIzaSy...';
```

## 배포 후 확인사항

### 웹
- [x] Vercel 배포 성공
- [x] 프로덕션 URL 접속 확인
- [ ] Supabase 연동 테스트
- [ ] 실시간 업데이트 테스트

### 앱
- [ ] APK 설치 테스트
- [ ] NFC 태그 인식 테스트
- [ ] QR 스캔 테스트
- [ ] AI 챗봇 테스트
- [ ] 음성 학습 테스트

## 문제 해결

### Kotlin 버전 이슈
settings.gradle 파일에서 Kotlin 버전 업데이트:
```gradle
id "org.jetbrains.kotlin.android" version "2.1.0" apply false
```

### 빌드 에러
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## 다음 단계

1. APK 파일 생성 확인
2. GitHub 저장소에 푸시
3. 테스트 및 버그 수정
4. 앱 스토어 배포 준비 (Google Play)

## 연락처
- GitHub: https://github.com/leeseongmin
- Vercel Dashboard: https://vercel.com/leeseongmins-projects-2832c478
