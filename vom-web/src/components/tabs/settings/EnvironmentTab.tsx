'use client';

import { useState, useEffect } from 'react';

interface EnvironmentTabProps {
  onLogout: () => void;
}

export default function EnvironmentTab({ onLogout }: EnvironmentTabProps) {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 600);
    return () => clearTimeout(timer);
  }, []);

  if (isLoading) {
    return (
      <div className="space-y-4 md:space-y-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden animate-pulse">
            <div className="px-4 md:px-6 py-4 border-b border-gray-100">
              <div className="h-5 w-24 bg-gray-200 rounded" />
            </div>
            <div className="divide-y divide-gray-100">
              {[1, 2, 3].map((j) => (
                <div key={j} className="px-4 md:px-6 py-4 flex items-center justify-between">
                  <div>
                    <div className="h-4 w-32 bg-gray-200 rounded mb-2" />
                    <div className="h-3 w-48 bg-gray-200 rounded" />
                  </div>
                  <div className="w-24 h-10 bg-gray-200 rounded-lg" />
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-4 md:space-y-6">
      {/* 일반 설정 */}
      <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
        <div className="px-4 md:px-6 py-4 border-b border-gray-100">
          <h3 className="text-sm md:text-base font-bold text-[#191F28]">일반 설정</h3>
        </div>
        <div className="divide-y divide-gray-100" role="list" aria-label="일반 설정 목록">
          <div className="px-4 md:px-6 py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">시스템 언어</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">관리자 대시보드 언어 설정</p>
            </div>
            <label className="sr-only" htmlFor="language-select">시스템 언어 선택</label>
            <select
              id="language-select"
              className="w-full sm:w-auto px-4 py-3 border border-gray-200 rounded-lg text-sm min-h-[44px]"
              aria-label="시스템 언어 선택"
            >
              <option>한국어</option>
              <option>English</option>
            </select>
          </div>
          <div className="px-4 md:px-6 py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">시간대</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">데이터 표시 시간대 설정</p>
            </div>
            <label className="sr-only" htmlFor="timezone-select">시간대 선택</label>
            <select
              id="timezone-select"
              className="w-full sm:w-auto px-4 py-3 border border-gray-200 rounded-lg text-sm min-h-[44px]"
              aria-label="시간대 선택"
            >
              <option>Asia/Seoul (UTC+9)</option>
              <option>UTC</option>
            </select>
          </div>
          <div className="px-4 md:px-6 py-4 flex items-center justify-between" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">다크 모드</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">어두운 테마 사용</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                aria-label="다크 모드 활성화"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
            </label>
          </div>
        </div>
      </div>

      {/* 알림 설정 */}
      <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
        <div className="px-4 md:px-6 py-4 border-b border-gray-100">
          <h3 className="text-sm md:text-base font-bold text-[#191F28]">알림 설정</h3>
        </div>
        <div className="divide-y divide-gray-100" role="list" aria-label="알림 설정 목록">
          <div className="px-4 md:px-6 py-4 flex items-center justify-between" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">이메일 알림</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">중요 알림을 이메일로 수신</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                defaultChecked
                aria-label="이메일 알림 활성화"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
            </label>
          </div>
          <div className="px-4 md:px-6 py-4 flex items-center justify-between" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">브라우저 알림</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">실시간 알림을 브라우저에서 수신</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                defaultChecked
                aria-label="브라우저 알림 활성화"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
            </label>
          </div>
          <div className="px-4 md:px-6 py-4 flex items-center justify-between" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">긴급 알림 사운드</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">긴급 알림 시 사운드 재생</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                aria-label="긴급 알림 사운드 활성화"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
            </label>
          </div>
        </div>
      </div>

      {/* 데이터 설정 */}
      <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
        <div className="px-4 md:px-6 py-4 border-b border-gray-100">
          <h3 className="text-sm md:text-base font-bold text-[#191F28]">데이터 설정</h3>
        </div>
        <div className="divide-y divide-gray-100" role="list" aria-label="데이터 설정 목록">
          <div className="px-4 md:px-6 py-4 flex items-center justify-between" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">자동 백업</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">매일 자동으로 데이터 백업</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                className="sr-only peer"
                defaultChecked
                aria-label="자동 백업 활성화"
              />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
            </label>
          </div>
          <div className="px-4 md:px-6 py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3" role="listitem">
            <div>
              <h4 className="font-bold text-[#191F28] text-sm md:text-base">데이터 보관 기간</h4>
              <p className="text-xs md:text-sm text-gray-400 mt-0.5">오래된 데이터 자동 삭제 기간</p>
            </div>
            <label className="sr-only" htmlFor="retention-select">데이터 보관 기간 선택</label>
            <select
              id="retention-select"
              className="w-full sm:w-auto px-4 py-3 border border-gray-200 rounded-lg text-sm min-h-[44px]"
              aria-label="데이터 보관 기간 선택"
            >
              <option>1년</option>
              <option>2년</option>
              <option>3년</option>
              <option>영구 보관</option>
            </select>
          </div>
        </div>
      </div>

      {/* 위험 영역 */}
      <div className="bg-red-50 rounded-[14px] md:rounded-[16px] border border-red-200 p-4 md:p-6">
        <h3 className="text-sm md:text-base font-bold text-red-600 mb-4">위험 영역</h3>
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h4 className="font-bold text-[#191F28] text-sm md:text-base">로그아웃</h4>
            <p className="text-xs md:text-sm text-gray-500 mt-0.5">현재 세션에서 로그아웃합니다.</p>
          </div>
          <button
            onClick={onLogout}
            className="w-full sm:w-auto px-6 py-3 bg-red-500 text-white rounded-lg text-sm font-bold hover:bg-red-600 transition-colors min-h-[44px]"
            aria-label="로그아웃"
          >
            로그아웃
          </button>
        </div>
      </div>
    </div>
  );
}
