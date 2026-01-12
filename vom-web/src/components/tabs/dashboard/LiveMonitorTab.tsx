'use client';

import { useState } from 'react';
import { LogEntry } from '@/types';

interface LiveMonitorTabProps {
  logs: LogEntry[];
}

export default function LiveMonitorTab({ logs }: LiveMonitorTabProps) {
  // 모니터링 제어 상태 (UI 연출용)
  const [isPaused, setIsPaused] = useState(false);
  const [filter, setFilter] = useState('all');

  return (
    <div className="space-y-6 font-pretendard animate-fade-in pb-10">
      
      {/* 1. 상단 관제 헤더 */}
      <div className="flex flex-col md:flex-row justify-between items-end md:items-center gap-4 mb-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
            </span>
            <h2 className="text-[22px] font-extrabold text-[#191F28] tracking-tight">실시간 모니터링</h2>
          </div>
          <p className="text-[13px] text-[#8B95A1] font-medium">
            현재 접속 중인 가정의 활동 데이터가 실시간으로 수집됩니다.
          </p>
        </div>

        {/* 컨트롤 버튼 그룹 */}
        <div className="flex items-center gap-3">
          <div className="flex bg-white rounded-[10px] border border-gray-200 p-1">
             <button 
                onClick={() => setFilter('all')}
                className={`px-3 py-1.5 text-[12px] font-bold rounded-[7px] transition-all ${filter === 'all' ? 'bg-gray-100 text-gray-900' : 'text-gray-400 hover:text-gray-600'}`}
             >
                전체
             </button>
             <button 
                onClick={() => setFilter('alert')}
                className={`px-3 py-1.5 text-[12px] font-bold rounded-[7px] transition-all ${filter === 'alert' ? 'bg-red-50 text-red-500' : 'text-gray-400 hover:text-gray-600'}`}
             >
                위급 알림
             </button>
          </div>
          <button
            onClick={() => setIsPaused(!isPaused)}
            className={`px-4 py-2 rounded-[10px] text-[13px] font-bold transition-all flex items-center gap-2 border ${
              isPaused
                ? 'bg-blue-50 text-[#3182F6] border-blue-100'
                : 'bg-white text-[#4E5968] border-gray-200 hover:bg-gray-50'
            }`}
          >
            {isPaused ? '▶ 재개' : '⏸ 일시정지'}
          </button>
        </div>
      </div>

      {/* 2. 실시간 상태 카드 (Grid System) */}
      <section className="grid grid-cols-1 md:grid-cols-3 gap-5">
        {/* Card 1: 접속자 */}
        <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-[0_2px_10px_rgba(0,0,0,0.03)] relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div>
              <p className="text-[13px] font-bold text-[#8B95A1] mb-1">실시간 접속</p>
              <h3 className="text-[32px] font-extrabold text-[#191F28] tracking-tight">
                42<span className="text-lg font-medium text-[#B0B8C1] ml-1">명</span>
              </h3>
            </div>
            <div className="w-10 h-10 rounded-[14px] bg-green-50 flex items-center justify-center text-green-500">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5.636 18.364a9 9 0 010-12.728m12.728 0a9 9 0 010 12.728m-9.9-2.829a5 5 0 010-7.07m7.072 0a5 5 0 010 7.07M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            </div>
          </div>
          <div className="flex items-center gap-1.5 text-[12px] font-bold text-green-600 bg-green-50 w-fit px-2 py-1 rounded-lg">
            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
            <span>3명 증가</span>
          </div>
        </div>

        {/* Card 2: 데이터 수집 */}
        <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-[0_2px_10px_rgba(0,0,0,0.03)] relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div>
              <p className="text-[13px] font-bold text-[#8B95A1] mb-1">금일 발화 데이터</p>
              <h3 className="text-[32px] font-extrabold text-[#3182F6] tracking-tight">
                156<span className="text-lg font-medium text-[#B0B8C1] ml-1">건</span>
              </h3>
            </div>
            <div className="w-10 h-10 rounded-[14px] bg-blue-50 flex items-center justify-center text-[#3182F6]">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" /></svg>
            </div>
          </div>
          <div className="flex items-center gap-1.5 text-[12px] font-bold text-blue-600 bg-blue-50 w-fit px-2 py-1 rounded-lg">
            <span>오늘 누적 합계</span>
          </div>
        </div>

        {/* Card 3: 알림 대기 */}
        <div className="bg-white rounded-[24px] p-6 border border-gray-100 shadow-[0_2px_10px_rgba(0,0,0,0.03)] relative overflow-hidden group">
          <div className="flex justify-between items-start mb-4">
            <div>
              <p className="text-[13px] font-bold text-[#8B95A1] mb-1">처리 대기 알림</p>
              <h3 className="text-[32px] font-extrabold text-orange-500 tracking-tight">
                3<span className="text-lg font-medium text-[#B0B8C1] ml-1">건</span>
              </h3>
            </div>
            <div className="w-10 h-10 rounded-[14px] bg-orange-50 flex items-center justify-center text-orange-500">
               <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
            </div>
          </div>
          <div className="flex items-center gap-1.5 text-[12px] font-bold text-orange-600 bg-orange-50 w-fit px-2 py-1 rounded-lg">
             <span>확인 필요</span>
          </div>
        </div>
      </section>

      {/* 3. 타임라인 스타일 로그 리스트 */}
      <section className="bg-white rounded-[24px] border border-gray-100 shadow-[0_4px_20px_rgba(0,0,0,0.02)] overflow-hidden flex flex-col h-[600px]">
        {/* 헤더 */}
        <div className="px-6 py-5 border-b border-gray-100 flex justify-between items-center bg-[#F9FAFB]/50 backdrop-blur-sm shrink-0">
             <div className="flex items-center gap-2">
                <h3 className="text-[16px] font-bold text-[#191F28]">Activity Stream</h3>
                <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-green-100 text-green-600">LIVE</span>
             </div>
             <span className="text-xs text-[#8B95A1] font-mono">Last updated: {new Date().toLocaleTimeString()}</span>
        </div>

        {/* 리스트 영역 */}
        <div className="flex-1 overflow-y-auto custom-scrollbar p-4">
            <div className="relative">
                {/* 세로 타임라인 선 */}
                <div className="absolute left-[29px] top-4 bottom-4 w-[2px] bg-gray-100 z-0"></div>

                <div className="space-y-1">
                  {logs.map((log) => (
                      <div key={log.id} className="relative flex items-center gap-4 p-3 rounded-[16px] hover:bg-[#F2F4F6] transition-colors group z-10">
                          
                          {/* 1. 타임라인 점 */}
                          <div className="relative shrink-0 w-8 flex justify-center">
                              <div className="w-3 h-3 rounded-full bg-white border-[3px] border-blue-500 shadow-sm z-10"></div>
                          </div>

                          {/* 2. 시간 정보 */}
                          <div className="w-20 shrink-0 flex flex-col items-start">
                              <span className="text-[13px] font-bold text-[#191F28] font-mono">{log.time}</span>
                          </div>

                          {/* 3. 사용자 정보 */}
                          <div className="w-36 shrink-0">
                               <div className="flex items-center gap-2">
                                  <div className="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center text-[10px] font-bold text-gray-500">
                                    {log.user.charAt(0)}
                                  </div>
                                  <div className="font-bold text-[14px] text-[#333D4B] truncate">{log.user}</div>
                               </div>
                          </div>

                          {/* 4. 카드 뱃지 */}
                          <div className="w-20 shrink-0">
                              <span className={`px-2 py-1 rounded-[6px] text-[11px] font-bold ${log.card.bgColor} ${log.card.textColor}`}>
                                  {log.card.name}
                              </span>
                          </div>

                          {/* 5. 발화 내용 (말풍선 스타일) */}
                          <div className="flex-1">
                              <div className="inline-block bg-[#F9FAFB] px-4 py-2 rounded-[12px] border border-transparent group-hover:border-gray-200 group-hover:bg-white transition-all">
                                 <p className="text-[13px] font-medium text-[#4E5968]">"{log.voice}"</p>
                              </div>
                          </div>

                          {/* 6. 액션 버튼 */}
                          <button className="w-8 h-8 flex items-center justify-center rounded-full text-gray-300 hover:bg-white hover:text-blue-500 hover:shadow-sm transition-all opacity-0 group-hover:opacity-100">
                              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" /></svg>
                          </button>
                      </div>
                  ))}
                </div>
            </div>
        </div>
      </section>
    </div>
  );
}