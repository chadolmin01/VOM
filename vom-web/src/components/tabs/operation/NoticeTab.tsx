'use client';

import { useState, useEffect } from 'react';
import AlertModal from '@/components/widgets/AlertModal';
import { EmptyState } from '@/components/ui';

const NOTICES = [
  { id: 1, title: '시스템 점검 안내', content: '1월 15일 오전 2시~4시 시스템 점검이 예정되어 있습니다.', type: '공지', date: '2025-01-12', views: 156, status: 'published' },
  { id: 2, title: '새해 첫 학습 이벤트', content: '1월 한 달간 매일 학습 시 추가 포인트를 드립니다.', type: '이벤트', date: '2025-01-01', views: 423, status: 'published' },
  { id: 3, title: '앱 업데이트 안내', content: '버전 2.1.0 업데이트가 출시되었습니다.', type: '업데이트', date: '2024-12-28', views: 289, status: 'published' },
  { id: 4, title: '설 연휴 운영 안내', content: '설 연휴 기간 고객센터 운영 시간 안내', type: '공지', date: '2025-01-20', views: 0, status: 'scheduled' },
];

const NOTIFICATIONS = [
  { id: 1, title: '학습 리마인더', target: '전체 대상자', type: 'push', scheduledAt: '매일 오전 9시', status: 'active' },
  { id: 2, title: '주간 리포트 알림', target: '보호자', type: 'email', scheduledAt: '매주 월요일 오전 10시', status: 'active' },
  { id: 3, title: '미접속 알림', target: '7일 미접속자', type: 'sms', scheduledAt: '자동', status: 'active' },
];

export default function NoticeTab() {
  const [showAlert, setShowAlert] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [notices, setNotices] = useState<typeof NOTICES>([]);
  const [notifications, setNotifications] = useState<typeof NOTIFICATIONS>([]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setNotices(NOTICES);
      setNotifications(NOTIFICATIONS);
      setIsLoading(false);
    }, 800);
    return () => clearTimeout(timer);
  }, []);

  const handleNotImplemented = () => setShowAlert(true);

  return (
    <>
      <div className="space-y-4 md:space-y-6">
        {/* 공지사항 섹션 */}
        <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
          <div className="px-4 md:px-6 py-4 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <h3 className="text-sm md:text-base font-bold text-[#191F28]">공지사항 관리</h3>
            <button
              onClick={handleNotImplemented}
              className="w-full sm:w-auto px-4 py-3 bg-[#3182F6] text-white rounded-lg text-sm font-bold hover:bg-[#1B64DA] min-h-[44px]"
              aria-label="새 공지사항 작성"
            >
              + 공지 작성
            </button>
          </div>

          {isLoading ? (
            <div className="divide-y divide-gray-100">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="px-4 md:px-6 py-4 animate-pulse">
                  <div className="flex items-center gap-4">
                    <div className="h-6 w-14 bg-gray-200 rounded-md" />
                    <div className="flex-1">
                      <div className="h-4 w-40 bg-gray-200 rounded mb-2" />
                      <div className="h-3 w-60 bg-gray-200 rounded" />
                    </div>
                    <div className="h-6 w-16 bg-gray-200 rounded-full" />
                  </div>
                </div>
              ))}
            </div>
          ) : notices.length === 0 ? (
            <EmptyState
              icon="📢"
              title="등록된 공지사항이 없습니다"
              description="새 공지사항을 작성하여 대상자들에게 알려보세요."
              actionLabel="+ 공지 작성"
              onAction={handleNotImplemented}
            />
          ) : (
            <>
              {/* 모바일: 카드 형태 */}
              <div className="md:hidden divide-y divide-gray-100">
                {notices.map((notice) => (
                  <div key={notice.id} className="p-4" role="article" aria-label={`${notice.title} 공지`}>
                    <div className="flex items-start justify-between mb-2">
                      <span className={`px-2.5 py-1 rounded-md text-xs font-bold ${
                        notice.type === '공지' ? 'bg-blue-50 text-blue-600' :
                        notice.type === '이벤트' ? 'bg-purple-50 text-purple-600' :
                        'bg-green-50 text-green-600'
                      }`}>
                        {notice.type}
                      </span>
                      <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        notice.status === 'published' ? 'bg-green-50 text-green-600' : 'bg-yellow-50 text-yellow-600'
                      }`}>
                        {notice.status === 'published' ? '게시됨' : '예약됨'}
                      </span>
                    </div>
                    <h4 className="font-bold text-[#191F28] mb-1">{notice.title}</h4>
                    <p className="text-sm text-gray-400 mb-3 line-clamp-2">{notice.content}</p>
                    <div className="flex items-center justify-between text-xs text-gray-400">
                      <span>{notice.date}</span>
                      <span>{notice.views} 조회</span>
                    </div>
                  </div>
                ))}
              </div>

              {/* 데스크탑: 리스트 형태 */}
              <div className="hidden md:block divide-y divide-gray-100" role="list" aria-label="공지사항 목록">
                {notices.map((notice) => (
                  <div key={notice.id} className="px-6 py-4 flex items-center justify-between hover:bg-gray-50" role="listitem">
                    <div className="flex items-center gap-4 flex-1">
                      <span className={`px-2.5 py-1 rounded-md text-xs font-bold ${
                        notice.type === '공지' ? 'bg-blue-50 text-blue-600' :
                        notice.type === '이벤트' ? 'bg-purple-50 text-purple-600' :
                        'bg-green-50 text-green-600'
                      }`}>
                        {notice.type}
                      </span>
                      <div className="flex-1">
                        <h4 className="font-bold text-[#191F28]">{notice.title}</h4>
                        <p className="text-sm text-gray-400 mt-0.5 truncate max-w-[400px]">{notice.content}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-6">
                      <span className="text-sm text-gray-400">{notice.date}</span>
                      <span className="text-sm text-gray-500">{notice.views} 조회</span>
                      <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        notice.status === 'published' ? 'bg-green-50 text-green-600' : 'bg-yellow-50 text-yellow-600'
                      }`}>
                        {notice.status === 'published' ? '게시됨' : '예약됨'}
                      </span>
                      <button
                        onClick={handleNotImplemented}
                        className="text-gray-400 hover:text-gray-600 p-2 rounded-lg hover:bg-gray-100 min-h-[36px] min-w-[36px] flex items-center justify-center"
                        aria-label={`${notice.title} 더보기 메뉴`}
                      >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                        </svg>
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>

        {/* 자동 알림 설정 */}
        <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
          <div className="px-4 md:px-6 py-4 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <div>
              <h3 className="text-sm md:text-base font-bold text-[#191F28]">자동 알림 설정</h3>
              <p className="text-xs md:text-sm text-gray-400 mt-1">대상자에게 자동으로 발송되는 알림을 관리합니다.</p>
            </div>
            <button
              onClick={handleNotImplemented}
              className="w-full sm:w-auto px-4 py-3 border border-gray-200 rounded-lg text-sm font-bold text-gray-600 hover:bg-gray-50 min-h-[44px]"
              aria-label="새 알림 추가"
            >
              + 알림 추가
            </button>
          </div>

          {isLoading ? (
            <div className="divide-y divide-gray-100">
              {[1, 2, 3].map((i) => (
                <div key={i} className="px-4 md:px-6 py-4 animate-pulse">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-[10px] bg-gray-200" />
                    <div className="flex-1">
                      <div className="h-4 w-32 bg-gray-200 rounded mb-2" />
                      <div className="h-3 w-48 bg-gray-200 rounded" />
                    </div>
                    <div className="w-11 h-6 bg-gray-200 rounded-full" />
                  </div>
                </div>
              ))}
            </div>
          ) : notifications.length === 0 ? (
            <EmptyState
              icon="🔔"
              title="설정된 자동 알림이 없습니다"
              description="자동 알림을 설정하여 대상자들에게 리마인더를 보내보세요."
              actionLabel="+ 알림 추가"
              onAction={handleNotImplemented}
            />
          ) : (
            <div className="divide-y divide-gray-100" role="list" aria-label="자동 알림 목록">
              {notifications.map((noti) => (
                <div key={noti.id} className="px-4 md:px-6 py-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3 hover:bg-gray-50" role="listitem">
                  <div className="flex items-center gap-3 md:gap-4">
                    <div className={`w-10 h-10 rounded-[10px] flex items-center justify-center flex-shrink-0 ${
                      noti.type === 'push' ? 'bg-blue-100 text-blue-600' :
                      noti.type === 'email' ? 'bg-purple-100 text-purple-600' :
                      'bg-green-100 text-green-600'
                    }`} aria-hidden="true">
                      {noti.type === 'push' ? (
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                        </svg>
                      ) : noti.type === 'email' ? (
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                        </svg>
                      ) : (
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
                        </svg>
                      )}
                    </div>
                    <div>
                      <h4 className="font-bold text-[#191F28]">{noti.title}</h4>
                      <p className="text-xs md:text-sm text-gray-400">{noti.target} · {noti.scheduledAt}</p>
                    </div>
                  </div>
                  <div className="flex items-center justify-between sm:justify-end gap-4">
                    <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                      noti.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'
                    }`}>
                      {noti.status === 'active' ? '활성' : '비활성'}
                    </span>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        className="sr-only peer"
                        defaultChecked={noti.status === 'active'}
                        aria-label={`${noti.title} 알림 ${noti.status === 'active' ? '비활성화' : '활성화'}`}
                      />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-[#3182F6] peer-focus:ring-offset-2 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#3182F6]"></div>
                    </label>
                  </div>
                </div>
              ))}
            </div>
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
