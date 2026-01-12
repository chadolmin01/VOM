'use client';

import { SAMPLE_USERS } from '@/constants';

export default function UsersTab() {
  return (
    <div className="bg-white border border-gray-200 rounded-[16px] shadow-sm p-8">
      <h3 className="text-lg font-bold text-[#191F28] mb-6">대상자 전체 목록</h3>
      <div className="space-y-2">
        {SAMPLE_USERS.map((user, idx) => (
          <div
            key={idx}
            className="flex items-center justify-between p-4 border border-gray-100 rounded-[12px] hover:border-blue-200 hover:bg-blue-50/30 transition-all"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center font-bold text-[#4E5968]">
                {user[0]}
              </div>
              <div>
                <div className="font-bold text-[#191F28]">{user}</div>
                <div className="text-xs text-[#8B95A1]">최근 접속: 10분 전</div>
              </div>
            </div>
            <button className="px-4 py-2 bg-white border border-gray-200 rounded-[8px] text-sm font-bold text-[#4E5968] hover:bg-gray-50">
              관리
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
