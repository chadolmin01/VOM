-- V.O.M Supabase 테이블 스키마 v2
-- UID 매핑 방식 (Dynamic Link)
-- Supabase SQL Editor에서 실행하세요

-- ============================================================
-- 1. 카드 콘텐츠 테이블 (서버에서 관리)
-- ============================================================
-- 콘텐츠는 여기서 관리 → 앱 업데이트 없이 수정 가능
CREATE TABLE IF NOT EXISTS card_contents (
  id TEXT PRIMARY KEY,              -- 카드 ID ('1', '2', 'vom-kit-001' 등)
  name TEXT NOT NULL,               -- 카드 이름 ('체온계', '약병' 등)
  icon TEXT DEFAULT '📦',           -- 이모지 아이콘
  scripts TEXT[] NOT NULL,          -- TTS 스크립트 배열
  audio_url TEXT,                   -- 오디오 파일 URL (선택)
  video_url TEXT,                   -- 비디오 URL (선택)
  quiz_question TEXT,               -- 퀴즈 질문
  quiz_options TEXT[],              -- 퀴즈 선택지 배열
  quiz_correct_index INTEGER DEFAULT 0, -- 정답 인덱스
  is_active BOOLEAN DEFAULT true,   -- 활성화 여부
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. NFC/QR 매핑 테이블 (UID → 콘텐츠 연결)
-- ============================================================
-- NFC 태그 UID만 있으면 됨 → 공장 발주 시 일련번호만 요청
CREATE TABLE IF NOT EXISTS nfc_card_mappings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nfc_tag_id TEXT UNIQUE,           -- NFC 태그 고유 UID (예: '04:A2:B3:C4:D5:E6:F7')
  qr_code TEXT UNIQUE,              -- QR 코드 값 (선택)
  card_id TEXT NOT NULL REFERENCES card_contents(id), -- 연결된 콘텐츠 ID
  label TEXT,                       -- 관리용 라벨 (예: 'vom-kit-001', '서울센터-체온계-01')
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. 사용자 테이블
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  device_id TEXT UNIQUE NOT NULL,
  name TEXT,
  user_type TEXT DEFAULT '일반',    -- 다문화, 한부모, 경계선, 일반
  region TEXT DEFAULT '미상',
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. 학습 로그 테이블
-- ============================================================
CREATE TABLE IF NOT EXISTS learning_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  card_id TEXT REFERENCES card_contents(id), -- 콘텐츠 ID 참조
  card_name TEXT NOT NULL,
  card_icon TEXT,
  speech_text TEXT,                 -- 사용자 발화 (STT 결과)
  quiz_correct BOOLEAN,
  risk_keywords TEXT[],             -- 감지된 위험 키워드
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. RLS 정책 (Row Level Security)
-- ============================================================
ALTER TABLE card_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE nfc_card_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_logs ENABLE ROW LEVEL SECURITY;

-- 모든 사용자 읽기/쓰기 가능 (데모용 - 프로덕션에서는 수정 필요)
CREATE POLICY "Allow all for card_contents" ON card_contents FOR ALL USING (true);
CREATE POLICY "Allow all for nfc_card_mappings" ON nfc_card_mappings FOR ALL USING (true);
CREATE POLICY "Allow all for users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all for learning_logs" ON learning_logs FOR ALL USING (true);

-- ============================================================
-- 6. 실시간 구독 활성화
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE card_contents;
ALTER PUBLICATION supabase_realtime ADD TABLE nfc_card_mappings;
ALTER PUBLICATION supabase_realtime ADD TABLE learning_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE users;

-- ============================================================
-- 7. 인덱스 (성능 최적화)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_nfc_mappings_tag_id ON nfc_card_mappings(nfc_tag_id);
CREATE INDEX IF NOT EXISTS idx_nfc_mappings_qr_code ON nfc_card_mappings(qr_code);
CREATE INDEX IF NOT EXISTS idx_nfc_mappings_card_id ON nfc_card_mappings(card_id);
CREATE INDEX IF NOT EXISTS idx_learning_logs_device_id ON learning_logs(device_id);
CREATE INDEX IF NOT EXISTS idx_learning_logs_completed_at ON learning_logs(completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_learning_logs_risk ON learning_logs(risk_keywords) WHERE risk_keywords IS NOT NULL;

-- ============================================================
-- 8. 초기 콘텐츠 데이터 (MVP용)
-- ============================================================
INSERT INTO card_contents (id, name, icon, scripts, video_url, quiz_question, quiz_options, quiz_correct_index) VALUES
(
  '1',
  '체온계',
  '🌡️',
  ARRAY[
    '체온계 사용법을 알려드릴게요.',
    '먼저 체온계 전원 버튼을 눌러주세요.',
    '삐 소리가 나면 아이 겨드랑이에 넣어주세요.',
    '다시 삐 소리가 날 때까지 기다려주세요.',
    '37.5도가 넘으면 열이 있는 거예요.'
  ],
  'https://www.youtube.com/watch?v=example1',
  '열이 있다고 판단하는 체온은?',
  ARRAY['36.5도', '37.5도', '38.5도'],
  1
),
(
  '2',
  '약병',
  '💊',
  ARRAY[
    '약 먹이는 방법을 알려드릴게요.',
    '먼저 약병을 흔들어 주세요.',
    '스포이드로 정해진 양만큼 빨아주세요.',
    '아이 입 안쪽 볼에 천천히 넣어주세요.',
    '다 먹으면 물을 조금 먹여주세요.'
  ],
  'https://www.youtube.com/watch?v=example2',
  '약을 먹일 때 어디에 넣어야 할까요?',
  ARRAY['혀 위에', '입 안쪽 볼에', '목구멍에'],
  1
),
(
  '3',
  '치약',
  '🦷',
  ARRAY[
    '아이 양치하는 방법이에요.',
    '칫솔에 콩알만큼 치약을 짜주세요.',
    '위에서 아래로 쓸어내려 주세요.',
    '바깥쪽, 안쪽, 씹는 면을 닦아주세요.',
    '물로 입을 헹궈주세요.'
  ],
  'https://www.youtube.com/watch?v=example3',
  '치약은 얼마나 짜야 할까요?',
  ARRAY['콩알만큼', '칫솔 가득', '손가락 한마디'],
  0
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  icon = EXCLUDED.icon,
  scripts = EXCLUDED.scripts,
  video_url = EXCLUDED.video_url,
  quiz_question = EXCLUDED.quiz_question,
  quiz_options = EXCLUDED.quiz_options,
  quiz_correct_index = EXCLUDED.quiz_correct_index,
  updated_at = NOW();
