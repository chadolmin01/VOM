'use client';

import { useState } from 'react';
import { TabType } from '@/types';

// 아이콘 컴포넌트 (인라인 SVG로 구현하여 별도 파일 없이 작동하게 함)
const Icons = {
  Dashboard: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path></svg>,
  Users: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>,
  Data: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>,
  Ops: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"></path></svg>,
  Settings: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>,
  ChevronDown: () => <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"></path></svg>,
  ChevronRight: () => <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7"></path></svg>,
  Logout: () => <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>,
};

// 메뉴 구조 정의
interface SubItem {
  id: TabType;
  label: string;
}

interface MenuGroup {
  id: string;
  label: string;
  icon: () => JSX.Element;
  subItems: SubItem[];
}

const MENU_STRUCTURE: MenuGroup[] = [
  {
    id: 'dashboard',
    label: '대시보드',
    icon: Icons.Dashboard,
    subItems: [
      { id: 'dashboard_overview', label: '종합 현황' },
      { id: 'dashboard_live', label: '실시간 모니터링' },
    ]
  },
  {
    id: 'users',
    label: '대상자 관리',
    icon: Icons.Users,
    subItems: [
      { id: 'users_list', label: '전체 대상자' },
      { id: 'users_group', label: '그룹 관리' },
    ]
  },
  {
    id: 'data',
    label: '학습 및 데이터',
    icon: Icons.Data,
    subItems: [
      { id: 'data_voice', label: '음성 데이터 분석' },
      { id: 'data_report', label: '학습 리포트' },
      { id: 'data_device', label: 'NFC/QR 매핑' },
    ]
  },
  {
    id: 'operation',
    label: '서비스 운영',
    icon: Icons.Ops,
    subItems: [
      { id: 'op_notice', label: '공지 및 알림' },
      { id: 'op_content', label: '콘텐츠 관리' },
    ]
  },
  {
    id: 'settings',
    label: '시스템 설정',
    icon: Icons.Settings,
    subItems: [
      { id: 'set_admin', label: '관리자 계정' },
      { id: 'set_env', label: '환경 설정' },
    ]
  },
];

interface SidebarProps {
  activeTab: TabType;
  onTabChange: (tab: TabType) => void;
  onLogout: () => void;
  isOpen: boolean;
  onClose: () => void;
}

export default function Sidebar({ activeTab, onTabChange, onLogout, isOpen, onClose }: SidebarProps) {
  // 어떤 메뉴 그룹이 열려있는지 상태 관리 (기본값: 대시보드)
  const [openGroups, setOpenGroups] = useState<string[]>(['dashboard']);

  const toggleGroup = (groupId: string) => {
    setOpenGroups(prev => 
      prev.includes(groupId) 
        ? prev.filter(id => id !== groupId) 
        : [...prev, groupId]
    );
  };

  return (
    <>
      {/* 모바일 오버레이 백드롭 */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-30 md:hidden"
          onClick={onClose}
        />
      )}

      <aside className={`
        fixed md:relative inset-y-0 left-0
        w-[260px] bg-[#1B1D25] text-white flex flex-col z-40 md:z-20 shrink-0 shadow-xl font-pretendard
        transform transition-transform duration-300 ease-in-out
        ${isOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
      `}>
        {/* 모바일 닫기 버튼 */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 text-gray-400 hover:text-white md:hidden"
        >
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        {/* 1. 로고 영역 */}
        <div className="h-[72px] flex items-center px-6 border-b border-gray-800/50">
        <div className="flex items-center gap-3">
          <span className="w-8 h-8 bg-[#3182F6] rounded-[8px] flex items-center justify-center text-white font-bold text-lg shadow-lg shadow-blue-500/20">
            V
          </span>
          <div>
            <h1 className="font-bold text-lg leading-none tracking-tight">V.O.M</h1>
            <span className="text-[10px] text-gray-500 font-medium tracking-wide">ADMIN CONSOLE</span>
          </div>
        </div>
      </div>

      {/* 2. 네비게이션 (스크롤 가능) */}
      <nav className="flex-1 px-3 py-6 space-y-1 overflow-y-auto custom-scrollbar">
        {MENU_STRUCTURE.map((group) => {
          const isActiveGroup = group.subItems.some(sub => sub.id === activeTab) || activeTab === group.id;
          const isOpen = openGroups.includes(group.id);

          return (
            <div key={group.id} className="mb-2">
              {/* 상위 메뉴 버튼 */}
              <button
                onClick={() => toggleGroup(group.id)}
                className={`w-full flex items-center justify-between px-3 py-3 rounded-[10px] text-[14px] font-medium transition-all duration-200 ${
                  isActiveGroup
                    ? 'text-white bg-gray-800/50'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800/30'
                }`}
              >
                <div className="flex items-center">
                  <span className={`mr-3 ${isActiveGroup ? 'text-[#3182F6]' : 'text-gray-500'}`}>
                    <group.icon />
                  </span>
                  {group.label}
                </div>
                <span className="text-gray-600">
                  {isOpen ? <Icons.ChevronDown /> : <Icons.ChevronRight />}
                </span>
              </button>

              {/* 하위 메뉴 리스트 (Accordion) */}
              <div 
                className={`overflow-hidden transition-all duration-300 ease-in-out ${
                  isOpen ? 'max-h-[500px] opacity-100 mt-1' : 'max-h-0 opacity-0'
                }`}
              >
                <div className="pl-11 pr-2 space-y-0.5 border-l border-gray-800 ml-5 my-1">
                  {group.subItems.map((sub) => (
                    <button
                      key={sub.id}
                      onClick={() => onTabChange(sub.id)}
                      className={`w-full text-left px-3 py-2 text-[13px] rounded-[6px] transition-colors relative ${
                        activeTab === sub.id
                          ? 'text-[#3182F6] font-bold bg-[#3182F6]/10'
                          : 'text-gray-500 hover:text-gray-300 hover:bg-gray-800/30'
                      }`}
                    >
                      {sub.label}
                      {activeTab === sub.id && (
                        <div className="absolute left-[-17px] top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-[#3182F6]"></div>
                      )}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          );
        })}
      </nav>

      {/* 3. 하단 프로필 */}
      <div className="p-4 bg-[#14161C] border-t border-gray-800/50">
        <div className="flex items-center gap-3 p-2 rounded-[10px] hover:bg-gray-800/50 transition-colors cursor-pointer group">
          <div className="w-9 h-9 rounded-full bg-gray-700 border border-gray-600 flex items-center justify-center text-xs font-bold text-gray-300 group-hover:border-gray-500">
            A
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-bold text-gray-200 truncate group-hover:text-white">수원시 다문화센터</p>
            <p className="text-xs text-gray-500 truncate">최고 관리자</p>
          </div>
          <button
            onClick={onLogout}
            className="text-gray-500 hover:text-red-400 transition-colors p-1.5 rounded-md hover:bg-red-400/10"
            title="로그아웃"
          >
            <Icons.Logout />
          </button>
        </div>
      </div>
      </aside>
    </>
  );
}