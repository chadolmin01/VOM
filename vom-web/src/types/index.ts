// 공통 타입 정의
export interface LogEntry {
  id: string;
  time: string;
  user: string;
  card: {
    name: string;
    type: string;
    bgColor: string;
    textColor: string;
  };
  voice: string;
  status: 'received' | 'pending';
}

export interface KPIItem {
  title: string;
  value: string;
  unit: string;
  change: string;
  isUp: boolean;
  alert?: boolean;
}

export interface NavItem {
  id: string;
  label: string;
  icon: React.ComponentType;
}

// 새로운 세부 탭 타입
export type TabType =
  | 'dashboard_overview'
  | 'dashboard_live'
  | 'users_list'
  | 'users_group'
  | 'data_voice'
  | 'data_report'
  | 'data_device'
  | 'op_notice'
  | 'op_content'
  | 'set_admin'
  | 'set_env';

export type LoginType = 'center' | 'admin';
export type UserType = 'multicultural' | 'government';
