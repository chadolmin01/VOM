import { createClient } from '@supabase/supabase-js';

// Supabase 설정 (Flutter 앱과 동일)
const SUPABASE_URL = 'https://ahcxzoqgetygljefifgr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoY3h6b3FnZXR5Z2xqZWZpZmdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMTg0MDUsImV4cCI6MjA4MzY5NDQwNX0.WVGNLC63tyW5Oq074yN0LItm3HbzglpCOo67XcILx_c';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ============================================================
// 타입 정의
// ============================================================

export interface CardContent {
  id: string;
  name: string;
  icon: string;
  scripts: string[];
  audio_url?: string;
  video_url?: string;
  quiz_question?: string;
  quiz_options?: string[];
  quiz_correct_index?: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface NfcCardMapping {
  id: string;
  nfc_tag_id?: string;
  qr_code?: string;
  card_id: string;
  label?: string;
  created_at: string;
  updated_at: string;
  card_contents?: CardContent;
}

export interface User {
  id: string;
  device_id: string;
  name?: string;
  user_type: string;
  region: string;
  phone?: string;
  created_at: string;
  last_active_at: string;
}

export interface LearningLog {
  id: string;
  user_id?: string;
  device_id: string;
  card_id?: string;
  card_name: string;
  card_icon?: string;
  speech_text?: string;
  quiz_correct?: boolean;
  risk_keywords?: string[];
  completed_at: string;
}

// ============================================================
// API 함수들
// ============================================================

// 카드 콘텐츠
export async function fetchCardContents(): Promise<CardContent[]> {
  const { data, error } = await supabase
    .from('card_contents')
    .select('*')
    .eq('is_active', true)
    .order('id');

  if (error) {
    console.error('Failed to fetch card contents:', error);
    return [];
  }
  return data || [];
}

// NFC/QR 매핑
export async function fetchMappings(): Promise<NfcCardMapping[]> {
  const { data, error } = await supabase
    .from('nfc_card_mappings')
    .select('*, card_contents(*)')
    .order('updated_at', { ascending: false });

  if (error) {
    console.error('Failed to fetch mappings:', error);
    return [];
  }
  return data || [];
}

export async function createMapping(mapping: {
  nfc_tag_id?: string;
  qr_code?: string;
  card_id: string;
  label?: string;
}): Promise<boolean> {
  const { error } = await supabase
    .from('nfc_card_mappings')
    .insert(mapping);

  if (error) {
    console.error('Failed to create mapping:', error);
    return false;
  }
  return true;
}

export async function updateMapping(id: string, mapping: {
  nfc_tag_id?: string;
  qr_code?: string;
  card_id?: string;
  label?: string;
}): Promise<boolean> {
  const { error } = await supabase
    .from('nfc_card_mappings')
    .update({ ...mapping, updated_at: new Date().toISOString() })
    .eq('id', id);

  if (error) {
    console.error('Failed to update mapping:', error);
    return false;
  }
  return true;
}

export async function deleteMapping(id: string): Promise<boolean> {
  const { error } = await supabase
    .from('nfc_card_mappings')
    .delete()
    .eq('id', id);

  if (error) {
    console.error('Failed to delete mapping:', error);
    return false;
  }
  return true;
}

// 사용자
export async function fetchUsers(): Promise<User[]> {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .order('last_active_at', { ascending: false });

  if (error) {
    console.error('Failed to fetch users:', error);
    return [];
  }
  return data || [];
}

// 학습 로그
export async function fetchLearningLogs(limit = 50): Promise<LearningLog[]> {
  const { data, error } = await supabase
    .from('learning_logs')
    .select('*')
    .order('completed_at', { ascending: false })
    .limit(limit);

  if (error) {
    console.error('Failed to fetch learning logs:', error);
    return [];
  }
  return data || [];
}

// 실시간 구독
export function subscribeToLearningLogs(
  onNewLog: (log: LearningLog) => void
) {
  const channel = supabase
    .channel('learning_logs_realtime')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'learning_logs',
      },
      (payload) => {
        onNewLog(payload.new as LearningLog);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}

// 통계 데이터
export async function fetchStats() {
  const [usersRes, logsRes, mappingsRes] = await Promise.all([
    supabase.from('users').select('id', { count: 'exact' }),
    supabase.from('learning_logs').select('id', { count: 'exact' }),
    supabase.from('nfc_card_mappings').select('id', { count: 'exact' }),
  ]);

  // 오늘 학습 수
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const { count: todayLogs } = await supabase
    .from('learning_logs')
    .select('id', { count: 'exact' })
    .gte('completed_at', today.toISOString());

  return {
    totalUsers: usersRes.count || 0,
    totalLogs: logsRes.count || 0,
    totalMappings: mappingsRes.count || 0,
    todayLogs: todayLogs || 0,
  };
}
