'use client';

import { useState, useEffect } from 'react';
import { SAMPLE_USERS } from '@/constants';
import { ListCardSkeleton, TableRowSkeleton, EmptyState } from '@/components/ui';
import AlertModal from '@/components/widgets/AlertModal';

export default function UsersListTab() {
  const [isLoading, setIsLoading] = useState(true);
  const [users, setUsers] = useState<string[]>([]);
  const [showAlert, setShowAlert] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState('전체 유형');

  useEffect(() => {
    const timer = setTimeout(() => {
      setUsers(SAMPLE_USERS);
      setIsLoading(false);
    }, 800);
    return () => clearTimeout(timer);
  }, []);

  const handleNotImplemented = () => setShowAlert(true);

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = filterType === '전체 유형' ||
      (filterType === '다문화가정' && user.includes('다문화')) ||
      (filterType === '한부모가정' && user.includes('한부모'));
    return matchesSearch && matchesFilter;
  });

  return (
    <>
      <div className="space-y-4 md:space-y-6">
        {/* 검색 & 필터 */}
        <div className="flex flex-col sm:flex-row justify-between items-stretch sm:items-center gap-3">
          <div className="flex flex-col sm:flex-row gap-2 sm:gap-3 flex-1">
            <label className="sr-only" htmlFor="user-search">대상자 검색</label>
            <input
              id="user-search"
              type="text"
              placeholder="이름, 연락처로 검색..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full sm:w-80 px-4 py-3 border border-gray-200 rounded-[10px] text-sm focus:border-[#3182F6] outline-none"
              aria-label="대상자 검색"
            />
            <label className="sr-only" htmlFor="user-filter">유형 필터</label>
            <select
              id="user-filter"
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="px-4 py-3 border border-gray-200 rounded-[10px] text-sm text-gray-600 outline-none"
              aria-label="유형 필터"
            >
              <option>전체 유형</option>
              <option>다문화가정</option>
              <option>한부모가정</option>
              <option>경계선 지능</option>
            </select>
          </div>
          <button
            onClick={handleNotImplemented}
            className="px-5 py-3 bg-[#3182F6] text-white rounded-[10px] text-sm font-bold hover:bg-[#1B64DA] transition-colors min-h-[44px]"
            aria-label="신규 대상자 등록"
          >
            + 신규 등록
          </button>
        </div>

        {/* 로딩 상태 */}
        {isLoading ? (
          <>
            {/* 모바일 스켈레톤 */}
            <div className="md:hidden space-y-3">
              {[1, 2, 3].map((i) => (
                <ListCardSkeleton key={i} />
              ))}
            </div>
            {/* 데스크탑 스켈레톤 */}
            <div className="hidden md:block bg-white rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
              <table className="w-full">
                <thead className="bg-[#F9FAFB] border-b border-gray-200">
                  <tr>
                    <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">대상자</th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">유형</th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">등록일</th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">최근 접속</th>
                    <th className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">학습 진도</th>
                    <th className="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase">관리</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {[1, 2, 3, 4].map((i) => (
                    <TableRowSkeleton key={i} columns={6} />
                  ))}
                </tbody>
              </table>
            </div>
          </>
        ) : filteredUsers.length === 0 ? (
          /* 빈 상태 */
          <div className="bg-white rounded-[16px] border border-gray-200 shadow-sm">
            <EmptyState
              icon="👥"
              title="등록된 대상자가 없습니다"
              description={searchQuery ? `"${searchQuery}" 검색 결과가 없습니다.` : "새로운 대상자를 등록해주세요."}
              actionLabel="+ 신규 등록"
              onAction={handleNotImplemented}
            />
          </div>
        ) : (
          <>
            {/* 모바일: 카드 형태 */}
            <div className="md:hidden space-y-3">
              {filteredUsers.map((user, idx) => (
                <div key={idx} className="bg-white rounded-[16px] border border-gray-200 shadow-sm p-4">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <div className="w-11 h-11 rounded-full bg-blue-50 flex items-center justify-center text-[#3182F6] font-bold" aria-hidden="true">
                        {user.charAt(0)}
                      </div>
                      <div>
                        <p className="font-bold text-[#191F28]">{user}</p>
                        <p className="text-xs text-gray-400">010-****-1234</p>
                      </div>
                    </div>
                    <span className="px-2.5 py-1 bg-purple-50 text-purple-600 rounded-md text-xs font-bold">
                      {user.includes('다문화') ? '다문화가정' : user.includes('한부모') ? '한부모가정' : '일반'}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-3 text-sm mb-3">
                    <div>
                      <p className="text-xs text-gray-400 mb-1">등록일</p>
                      <p className="text-gray-600">2024.01.10</p>
                    </div>
                    <div>
                      <p className="text-xs text-gray-400 mb-1">최근 접속</p>
                      <p className="text-gray-600">10분 전</p>
                    </div>
                  </div>

                  <div className="mb-4">
                    <p className="text-xs text-gray-400 mb-2">학습 진도</p>
                    <div className="flex items-center gap-2">
                      <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden" role="progressbar" aria-valuenow={70 + idx * 5} aria-valuemin={0} aria-valuemax={100}>
                        <div className="h-full bg-[#3182F6] rounded-full" style={{ width: `${70 + idx * 5}%` }}></div>
                      </div>
                      <span className="text-sm font-bold text-[#3182F6]">{70 + idx * 5}%</span>
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={handleNotImplemented}
                      className="flex-1 py-3 border border-gray-200 rounded-lg text-sm font-bold text-gray-500 hover:bg-gray-50 min-h-[44px]"
                      aria-label={`${user} 상세 정보 보기`}
                    >
                      상세
                    </button>
                    <button
                      onClick={handleNotImplemented}
                      className="flex-1 py-3 border border-blue-200 rounded-lg text-sm font-bold text-[#3182F6] hover:bg-blue-50 min-h-[44px]"
                      aria-label={`${user}에게 알림 보내기`}
                    >
                      알림
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* 데스크탑: 테이블 형태 */}
            <div className="hidden md:block bg-white rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
              <table className="w-full" role="table" aria-label="대상자 목록">
                <thead className="bg-[#F9FAFB] border-b border-gray-200">
                  <tr>
                    <th scope="col" className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">대상자</th>
                    <th scope="col" className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">유형</th>
                    <th scope="col" className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">등록일</th>
                    <th scope="col" className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">최근 접속</th>
                    <th scope="col" className="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">학습 진도</th>
                    <th scope="col" className="px-6 py-4 text-right text-xs font-bold text-gray-500 uppercase">관리</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {filteredUsers.map((user, idx) => (
                    <tr key={idx} className="hover:bg-blue-50/30 transition-colors">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-[#3182F6] font-bold" aria-hidden="true">
                            {user.charAt(0)}
                          </div>
                          <div>
                            <p className="font-bold text-[#191F28]">{user}</p>
                            <p className="text-xs text-gray-400">010-****-1234</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="px-2.5 py-1 bg-purple-50 text-purple-600 rounded-md text-xs font-bold">
                          {user.includes('다문화') ? '다문화가정' : user.includes('한부모') ? '한부모가정' : '일반'}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">2024.01.10</td>
                      <td className="px-6 py-4 text-sm text-gray-500">10분 전</td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                          <div className="w-24 h-2 bg-gray-100 rounded-full overflow-hidden" role="progressbar" aria-valuenow={70 + idx * 5} aria-valuemin={0} aria-valuemax={100}>
                            <div className="h-full bg-[#3182F6] rounded-full" style={{ width: `${70 + idx * 5}%` }}></div>
                          </div>
                          <span className="text-sm font-bold text-[#3182F6]">{70 + idx * 5}%</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button
                          onClick={handleNotImplemented}
                          className="px-4 py-2 border border-gray-200 rounded-md text-xs font-bold text-gray-500 hover:bg-gray-50 mr-2 min-h-[36px]"
                          aria-label={`${user} 상세 정보 보기`}
                        >
                          상세
                        </button>
                        <button
                          onClick={handleNotImplemented}
                          className="px-4 py-2 border border-blue-200 rounded-md text-xs font-bold text-[#3182F6] hover:bg-blue-50 min-h-[36px]"
                          aria-label={`${user}에게 알림 보내기`}
                        >
                          알림
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
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
