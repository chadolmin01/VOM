'use client';

import { useState } from 'react';
import { TabType } from '@/types';
import AlertModal from '@/components/widgets/AlertModal';

interface HeaderProps {
  activeTab: TabType;
  onMenuClick: () => void;
}

const tabTitles: Record<TabType, string> = {
  // Dashboard
  dashboard_overview: '종합 현황',
  dashboard_live: '실시간 모니터링',

  // Users
  users_list: '전체 대상자',
  users_group: '그룹 관리',

  // Data
  data_voice: '음성 데이터 분석',
  data_report: '학습 리포트',
  data_device: 'NFC/QR 매핑 관리',

  // Operation
  op_notice: '공지 및 알림',
  op_content: '콘텐츠 관리',

  // Settings
  set_admin: '관리자 계정',
  set_env: '환경 설정',
};

export default function Header({ activeTab, onMenuClick }: HeaderProps) {
  const [showAlert, setShowAlert] = useState(false);

  const today = new Date().toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return (
    <>
      <header className="h-[60px] md:h-[76px] bg-white border-b border-gray-200 flex justify-between items-center px-4 md:px-8 shrink-0 z-10">
        <div className="flex items-center gap-3">
          {/* 모바일 햄버거 메뉴 버튼 */}
          <button
            onClick={onMenuClick}
            className="p-2 -ml-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg md:hidden"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <h2 className="text-[18px] md:text-[22px] font-bold text-[#191F28]">
            {tabTitles[activeTab]}
          </h2>
        </div>
        <div className="flex gap-2 md:gap-3">
          <div className="hidden sm:flex h-10 px-4 items-center bg-[#F9FAFB] border border-[#E5E8EB] rounded-[10px] text-[15px] text-[#8B95A1]">
            <span className="mr-2">📅</span> {today}
          </div>
          <button
            onClick={() => setShowAlert(true)}
            className="h-9 md:h-10 px-3 md:px-5 bg-[#3182F6] text-white rounded-[10px] text-[13px] md:text-[15px] font-bold hover:bg-[#1B64DA] transition-colors shadow-sm"
          >
            리포트 생성
          </button>
        </div>
      </header>

      <AlertModal
        isOpen={showAlert}
        type="info"
        title="준비 중인 기능입니다"
        description="리포트 생성 기능은 현재 개발 중입니다.\n빠른 시일 내에 제공될 예정입니다."
        onClose={() => setShowAlert(false)}
        confirmText="확인"
      />
    </>
  );
}
