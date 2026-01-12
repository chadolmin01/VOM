'use client';

import { useState, useEffect } from 'react';
import AlertModal from '@/components/widgets/AlertModal';
import { CardSkeleton, TableRowSkeleton, EmptyState } from '@/components/ui';

const ADMINS = [
  { id: 1, name: '관리자1', email: 'admin1@vom.kr', role: '슈퍼관리자', lastLogin: '2025-01-12 10:30', status: 'active' },
  { id: 2, name: '관리자2', email: 'admin2@vom.kr', role: '일반관리자', lastLogin: '2025-01-11 15:45', status: 'active' },
  { id: 3, name: '센터장A', email: 'center.a@vom.kr', role: '센터관리자', lastLogin: '2025-01-10 09:20', status: 'active' },
  { id: 4, name: '센터장B', email: 'center.b@vom.kr', role: '센터관리자', lastLogin: '2024-12-28 14:10', status: 'inactive' },
];

export default function AdminAccountTab() {
  const [showAlert, setShowAlert] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [admins, setAdmins] = useState<typeof ADMINS>([]);

  useEffect(() => {
    const timer = setTimeout(() => {
      setAdmins(ADMINS);
      setIsLoading(false);
    }, 800);
    return () => clearTimeout(timer);
  }, []);

  const handleNotImplemented = () => setShowAlert(true);

  const activeCount = admins.filter(a => a.status === 'active').length;
  const inactiveCount = admins.filter(a => a.status === 'inactive').length;

  return (
    <>
      <div className="space-y-4 md:space-y-6">
        {/* 관리자 통계 */}
        <div className="grid grid-cols-3 gap-2 md:gap-4">
          {isLoading ? (
            [1, 2, 3].map((i) => <CardSkeleton key={i} />)
          ) : (
            <>
              <div className="bg-white rounded-[12px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">전체 관리자</p>
                <p className="text-2xl md:text-3xl font-extrabold text-[#191F28]">{admins.length}</p>
              </div>
              <div className="bg-white rounded-[12px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">활성 계정</p>
                <p className="text-2xl md:text-3xl font-extrabold text-green-600">{activeCount}</p>
              </div>
              <div className="bg-white rounded-[12px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
                <p className="text-xs md:text-sm font-bold text-gray-500 mb-1 md:mb-2">비활성 계정</p>
                <p className="text-2xl md:text-3xl font-extrabold text-gray-400">{inactiveCount}</p>
              </div>
            </>
          )}
        </div>

        {/* 관리자 목록 */}
        <div className="bg-white rounded-[12px] md:rounded-[16px] border border-gray-200 shadow-sm overflow-hidden">
          <div className="px-4 md:px-6 py-4 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
            <h3 className="text-sm md:text-base font-bold text-[#191F28]">관리자 계정 관리</h3>
            <button
              onClick={handleNotImplemented}
              className="w-full sm:w-auto px-4 py-3 bg-[#3182F6] text-white rounded-lg text-sm font-bold hover:bg-[#1B64DA] min-h-[44px]"
              aria-label="새 관리자 추가"
            >
              + 관리자 추가
            </button>
          </div>

          {isLoading ? (
            <>
              {/* 모바일 스켈레톤 */}
              <div className="md:hidden divide-y divide-gray-100">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="p-4 animate-pulse">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-11 h-11 rounded-full bg-gray-200" />
                      <div className="flex-1">
                        <div className="h-4 w-24 bg-gray-200 rounded mb-2" />
                        <div className="h-3 w-32 bg-gray-200 rounded" />
                      </div>
                      <div className="h-6 w-14 bg-gray-200 rounded-full" />
                    </div>
                    <div className="flex gap-2">
                      <div className="flex-1 h-10 bg-gray-200 rounded-lg" />
                      <div className="flex-1 h-10 bg-gray-200 rounded-lg" />
                    </div>
                  </div>
                ))}
              </div>
              {/* 데스크탑 스켈레톤 */}
              <table className="hidden md:table w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">관리자</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">이메일</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">권한</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">마지막 로그인</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">상태</th>
                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500">관리</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {[1, 2, 3, 4].map((i) => (
                    <TableRowSkeleton key={i} columns={6} />
                  ))}
                </tbody>
              </table>
            </>
          ) : admins.length === 0 ? (
            <EmptyState
              icon="👤"
              title="등록된 관리자가 없습니다"
              description="새 관리자를 추가하여 시스템을 관리하세요."
              actionLabel="+ 관리자 추가"
              onAction={handleNotImplemented}
            />
          ) : (
            <>
              {/* 모바일: 카드 형태 */}
              <div className="md:hidden divide-y divide-gray-100">
                {admins.map((admin) => (
                  <div key={admin.id} className="p-4" role="article" aria-label={`${admin.name} 관리자 계정`}>
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="w-11 h-11 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-bold text-sm" aria-hidden="true">
                          {admin.name.charAt(0)}
                        </div>
                        <div>
                          <span className="font-bold text-[#191F28]">{admin.name}</span>
                          <p className="text-xs text-gray-400">{admin.email}</p>
                        </div>
                      </div>
                      <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                        admin.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'
                      }`}>
                        {admin.status === 'active' ? '활성' : '비활성'}
                      </span>
                    </div>

                    <div className="flex items-center justify-between mb-3">
                      <span className={`px-2.5 py-1 rounded-md text-xs font-bold ${
                        admin.role === '슈퍼관리자' ? 'bg-purple-50 text-purple-600' :
                        admin.role === '일반관리자' ? 'bg-blue-50 text-blue-600' :
                        'bg-green-50 text-green-600'
                      }`}>
                        {admin.role}
                      </span>
                      <span className="text-xs text-gray-400">최근: {admin.lastLogin}</span>
                    </div>

                    <div className="flex gap-2">
                      <button
                        onClick={handleNotImplemented}
                        className="flex-1 py-3 border border-blue-200 text-[#3182F6] text-sm font-bold rounded-lg hover:bg-blue-50 min-h-[44px]"
                        aria-label={`${admin.name} 정보 수정`}
                      >
                        수정
                      </button>
                      <button
                        onClick={handleNotImplemented}
                        className="flex-1 py-3 border border-gray-200 text-gray-500 text-sm font-bold rounded-lg hover:bg-gray-50 min-h-[44px]"
                        aria-label={`${admin.name} 권한 변경`}
                      >
                        권한변경
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              {/* 데스크탑: 테이블 형태 */}
              <table className="hidden md:table w-full" role="table" aria-label="관리자 계정 목록">
                <thead className="bg-gray-50">
                  <tr>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">관리자</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">이메일</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">권한</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">마지막 로그인</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">상태</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-bold text-gray-500">관리</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {admins.map((admin) => (
                    <tr key={admin.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-500 flex items-center justify-center text-white font-bold text-sm" aria-hidden="true">
                            {admin.name.charAt(0)}
                          </div>
                          <span className="font-bold text-[#191F28]">{admin.name}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">{admin.email}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2.5 py-1 rounded-md text-xs font-bold ${
                          admin.role === '슈퍼관리자' ? 'bg-purple-50 text-purple-600' :
                          admin.role === '일반관리자' ? 'bg-blue-50 text-blue-600' :
                          'bg-green-50 text-green-600'
                        }`}>
                          {admin.role}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500">{admin.lastLogin}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
                          admin.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-gray-100 text-gray-500'
                        }`}>
                          {admin.status === 'active' ? '활성' : '비활성'}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex gap-2">
                          <button
                            onClick={handleNotImplemented}
                            className="px-4 py-2 text-[#3182F6] text-sm font-bold hover:bg-blue-50 rounded-lg min-h-[36px]"
                            aria-label={`${admin.name} 정보 수정`}
                          >
                            수정
                          </button>
                          <button
                            onClick={handleNotImplemented}
                            className="px-4 py-2 text-gray-400 text-sm font-bold hover:bg-gray-100 rounded-lg min-h-[36px]"
                            aria-label={`${admin.name} 권한 변경`}
                          >
                            권한변경
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </>
          )}
        </div>

        {/* 권한 설명 */}
        <div className="bg-blue-50 rounded-[12px] md:rounded-[16px] p-4 md:p-6">
          <h4 className="font-bold text-[#191F28] mb-3 md:mb-4 text-sm md:text-base">권한 레벨 안내</h4>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 md:gap-4" role="list" aria-label="권한 레벨 설명">
            <div className="bg-white rounded-lg p-3 md:p-4" role="listitem">
              <span className="px-2 py-1 bg-purple-50 text-purple-600 text-xs font-bold rounded-md">슈퍼관리자</span>
              <p className="text-xs md:text-sm text-gray-500 mt-2">모든 기능 접근 및 관리자 계정 관리 권한</p>
            </div>
            <div className="bg-white rounded-lg p-3 md:p-4" role="listitem">
              <span className="px-2 py-1 bg-blue-50 text-blue-600 text-xs font-bold rounded-md">일반관리자</span>
              <p className="text-xs md:text-sm text-gray-500 mt-2">대상자 관리 및 데이터 조회 권한</p>
            </div>
            <div className="bg-white rounded-lg p-3 md:p-4" role="listitem">
              <span className="px-2 py-1 bg-green-50 text-green-600 text-xs font-bold rounded-md">센터관리자</span>
              <p className="text-xs md:text-sm text-gray-500 mt-2">소속 센터 대상자만 조회 가능</p>
            </div>
          </div>
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
