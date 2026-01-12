'use client';

import { useState, useEffect } from 'react';
import AlertModal from '@/components/widgets/AlertModal';
import { CardSkeleton, EmptyState } from '@/components/ui';

const REPORTS = [
  { id: 1, title: '주간 학습 리포트', period: '2025.01.06 ~ 01.12', type: '주간', status: 'ready', users: 45 },
  { id: 2, title: '월간 종합 리포트', period: '2024.12.01 ~ 12.31', type: '월간', status: 'ready', users: 52 },
  { id: 3, title: '개인별 상세 리포트', period: '2025.01.01 ~ 01.12', type: '개인', status: 'generating', users: 1 },
  { id: 4, title: '그룹 비교 리포트', period: '2025.01.01 ~ 01.12', type: '그룹', status: 'ready', users: 28 },
];

export default function ReportTab() {
  const [showAlert, setShowAlert] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [reports, setReports] = useState<typeof REPORTS>([]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setReports(REPORTS);
      setIsLoading(false);
    }, 800);
    return () => clearTimeout(timer);
  }, []);

  const handleNotImplemented = () => setShowAlert(true);

  return (
    <>
      <div className="space-y-4 md:space-y-6">
        {/* 리포트 생성 섹션 */}
        <div className="bg-gradient-to-r from-[#3182F6] to-[#1B64DA] rounded-[14px] md:rounded-[16px] p-4 md:p-6 text-white">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
              <h3 className="text-lg md:text-xl font-bold mb-1 md:mb-2">새 리포트 생성</h3>
              <p className="text-blue-100 text-xs md:text-sm">대상자별, 기간별 학습 리포트를 생성하고 관리하세요.</p>
            </div>
            <button
              onClick={handleNotImplemented}
              className="w-full sm:w-auto px-5 py-3 bg-white text-[#3182F6] rounded-[10px] font-bold hover:bg-blue-50 transition-colors min-h-[44px]"
              aria-label="새 리포트 생성"
            >
              + 리포트 생성
            </button>
          </div>
        </div>

        {/* 리포트 통계 */}
        <div className="grid grid-cols-3 gap-3 md:gap-4">
          {isLoading ? (
            [1, 2, 3].map((i) => <CardSkeleton key={i} />)
          ) : (
            <>
              <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">생성된 리포트</p>
                <p className="text-2xl md:text-3xl font-extrabold text-[#191F28]">156</p>
                <p className="text-[10px] md:text-xs text-gray-400 mt-1">누적 기준</p>
              </div>
              <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">이번 주 생성</p>
                <p className="text-2xl md:text-3xl font-extrabold text-[#3182F6]">12</p>
                <p className="text-[10px] md:text-xs text-green-500 mt-1">+4 전주 대비</p>
              </div>
              <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">다운로드 수</p>
                <p className="text-2xl md:text-3xl font-extrabold text-green-500">89</p>
                <p className="text-[10px] md:text-xs text-gray-400 mt-1">이번 달</p>
              </div>
            </>
          )}
        </div>

        {/* 리포트 목록 */}
        <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
          <div className="px-4 md:px-6 py-4 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <h3 className="text-sm md:text-base font-bold text-[#191F28]">리포트 목록</h3>
            <div className="flex gap-2 w-full sm:w-auto">
              <label className="sr-only" htmlFor="report-type-filter">리포트 유형 필터</label>
              <select
                id="report-type-filter"
                className="flex-1 sm:flex-none px-3 py-2.5 border border-gray-200 rounded-lg text-sm min-h-[44px]"
                aria-label="리포트 유형 필터"
              >
                <option>전체 유형</option>
                <option>주간</option>
                <option>월간</option>
                <option>개인</option>
                <option>그룹</option>
              </select>
            </div>
          </div>

          {isLoading ? (
            <div className="divide-y divide-gray-100">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="px-4 md:px-6 py-4 animate-pulse">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 md:w-12 md:h-12 rounded-[10px] md:rounded-[12px] bg-gray-200" />
                    <div className="flex-1">
                      <div className="h-4 w-32 bg-gray-200 rounded mb-2" />
                      <div className="h-3 w-24 bg-gray-200 rounded" />
                    </div>
                    <div className="h-6 w-16 bg-gray-200 rounded-full" />
                  </div>
                </div>
              ))}
            </div>
          ) : reports.length === 0 ? (
            <EmptyState
              icon="📊"
              title="생성된 리포트가 없습니다"
              description="새 리포트를 생성하여 학습 현황을 분석해보세요."
              actionLabel="+ 리포트 생성"
              onAction={handleNotImplemented}
            />
          ) : (
            <>
              {/* 모바일: 카드 형태 */}
              <div className="md:hidden divide-y divide-gray-100">
                {reports.map((report) => (
                  <div key={report.id} className="p-4" role="article" aria-label={`${report.title} 리포트`}>
                    <div className="flex items-start gap-3 mb-3">
                      <div className={`w-10 h-10 rounded-[10px] flex items-center justify-center flex-shrink-0 ${
                        report.type === '주간' ? 'bg-blue-100 text-blue-600' :
                        report.type === '월간' ? 'bg-purple-100 text-purple-600' :
                        report.type === '개인' ? 'bg-green-100 text-green-600' :
                        'bg-orange-100 text-orange-600'
                      }`} aria-hidden="true">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="font-bold text-[#191F28] truncate">{report.title}</h4>
                        <p className="text-xs text-gray-400 mt-0.5">{report.period}</p>
                      </div>
                    </div>

                    <div className="flex items-center justify-between mb-3">
                      <span className="text-sm text-gray-500">{report.users}명 대상</span>
                      <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        report.status === 'ready' ? 'bg-green-50 text-green-600' : 'bg-yellow-50 text-yellow-600'
                      }`}>
                        {report.status === 'ready' ? '완료' : '생성 중'}
                      </span>
                    </div>

                    {report.status === 'ready' && (
                      <button
                        onClick={handleNotImplemented}
                        className="w-full py-3 border border-gray-200 rounded-lg text-sm font-bold text-gray-600 hover:bg-gray-50 min-h-[44px]"
                        aria-label={`${report.title} 다운로드`}
                      >
                        다운로드
                      </button>
                    )}
                  </div>
                ))}
              </div>

              {/* 데스크탑: 리스트 형태 */}
              <div className="hidden md:block divide-y divide-gray-100" role="list" aria-label="리포트 목록">
                {reports.map((report) => (
                  <div key={report.id} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50" role="listitem">
                    <div className="flex items-center gap-4">
                      <div className={`w-12 h-12 rounded-[12px] flex items-center justify-center ${
                        report.type === '주간' ? 'bg-blue-100 text-blue-600' :
                        report.type === '월간' ? 'bg-purple-100 text-purple-600' :
                        report.type === '개인' ? 'bg-green-100 text-green-600' :
                        'bg-orange-100 text-orange-600'
                      }`} aria-hidden="true">
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                      </div>
                      <div>
                        <h4 className="font-bold text-[#191F28]">{report.title}</h4>
                        <p className="text-sm text-gray-400 mt-0.5">{report.period}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <span className="text-sm text-gray-500">{report.users}명 대상</span>
                      <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        report.status === 'ready' ? 'bg-green-50 text-green-600' : 'bg-yellow-50 text-yellow-600'
                      }`}>
                        {report.status === 'ready' ? '완료' : '생성 중'}
                      </span>
                      {report.status === 'ready' && (
                        <button
                          onClick={handleNotImplemented}
                          className="px-4 py-2 border border-gray-200 rounded-lg text-sm font-bold text-gray-600 hover:bg-gray-50 min-h-[36px]"
                          aria-label={`${report.title} 다운로드`}
                        >
                          다운로드
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      </div>

      <AlertModal
        isOpen={showAlert}
        type="info"
        title="준비 중인 기능입니다"
        description="해당 기능은 현재 개발 중입니다.\n빠른 시일 내에 제공될 예정입니다."
        onClose={() => setShowAlert(false)}
        confirmText="확인"
      />
    </>
  );
}
