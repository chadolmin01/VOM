'use client';

import { useState } from 'react';
import { LogEntry } from '@/types';
import KPICards from '@/components/dashboard/KPICards';
import Charts from '@/components/dashboard/Charts';
import ActivityLog from '@/components/dashboard/ActivityLog';

interface OverviewTabProps {
  logs: LogEntry[];
}

export default function OverviewTab({ logs }: OverviewTabProps) {
  // 기간 필터 상태 (예시)
  const [period, setPeriod] = useState('week');

  return (
    <div className="space-y-6 font-pretendard animate-fade-in pb-10">
      
      {/* 1. 상단 컨트롤 바 (기간 선택 및 타이틀) */}
      <div className="flex flex-col sm:flex-row justify-between items-end sm:items-center gap-4 mb-2">
        <div>
          <h2 className="text-[22px] font-extrabold text-[#191F28] tracking-tight">종합 현황</h2>
          <p className="text-[13px] text-[#8B95A1] font-medium mt-1">
            실시간 학습 데이터 및 참여 현황을 한눈에 확인하세요.
          </p>
        </div>
        
        {/* 기간 필터 (토스 스타일 Segmented Control) */}
        <div className="bg-white p-1 rounded-xl shadow-sm border border-gray-100 flex">
          {[
            { id: 'today', label: '오늘' },
            { id: 'week', label: '이번 주' },
            { id: 'month', label: '이번 달' }
          ].map((item) => (
            <button
              key={item.id}
              onClick={() => setPeriod(item.id)}
              className={`px-4 py-1.5 text-[13px] font-bold rounded-[8px] transition-all ${
                period === item.id
                  ? 'bg-[#E8F3FF] text-[#3182F6]'
                  : 'text-[#6B7684] hover:bg-gray-50'
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>
      </div>

      {/* 2. 핵심 지표 (KPI Cards) */}
      <section>
        <KPICards period={period} />
      </section>

      {/* 3. 차트 영역 (2열 그리드: 왼쪽 메인, 오른쪽 서브) */}
      <section className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-3">
          <Charts period={period} />
        </div>
      </section>

      {/* 4. 실시간 로그 (Activity Log) */}
      <section>
        <ActivityLog logs={logs} />
      </section>

      {/* 하단 푸터 (저작권/문의) */}
      <div className="text-center pt-8 border-t border-gray-100">
         <p className="text-[11px] text-[#B0B8C1]">
           데이터 갱신 시간: {new Date().toLocaleTimeString()} • 시스템 문의: 1661-0000
         </p>
      </div>
    </div>
  );
}