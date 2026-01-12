'use client';

import { LogEntry } from '@/types';

interface ActivityLogProps {
  logs: LogEntry[];
}

export default function ActivityLog({ logs }: ActivityLogProps) {
  return (
    <div className="bg-white border border-gray-200 rounded-[18px] shadow-[0_2px_8px_rgba(0,0,0,0.04)] overflow-hidden">
      <div className="px-7 py-5 border-b border-gray-200 flex justify-between items-center">
        <div className="flex items-center gap-2">
          <h3 className="text-[19px] font-bold text-[#191F28]">실시간 활동 로그</h3>
          <span className="w-2.5 h-2.5 rounded-full bg-green-500 animate-pulse"></span>
        </div>
        <button className="text-[15px] font-bold text-[#8B95A1] hover:text-[#191F28] transition-colors">
          전체 내역 보기 &gt;
        </button>
      </div>
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-[#F9FAFB] border-b border-gray-200">
            <th className="px-7 py-3.5 text-[13px] font-bold text-[#8B95A1] uppercase w-[15%]">시간</th>
            <th className="px-6 py-3.5 text-[13px] font-bold text-[#8B95A1] uppercase w-[15%]">대상자</th>
            <th className="px-6 py-3.5 text-[13px] font-bold text-[#8B95A1] uppercase w-[15%]">학습 카드</th>
            <th className="px-6 py-3.5 text-[13px] font-bold text-[#8B95A1] uppercase w-[40%]">발화 데이터</th>
            <th className="px-6 py-3.5 text-[13px] font-bold text-[#8B95A1] uppercase w-[15%] text-right">상태</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {logs.map((log) => (
            <tr key={log.id} className="hover:bg-blue-50/30 transition-colors group">
              <td className="px-7 py-4 text-[15px] font-medium text-[#6B7684] tabular-nums">{log.time}</td>
              <td className="px-6 py-4 text-[15px] font-bold text-[#191F28]">{log.user}</td>
              <td className="px-6 py-4">
                <span className={`inline-flex items-center px-3 py-1.5 rounded-[8px] text-[13px] font-bold ${log.card.bgColor} ${log.card.textColor}`}>
                  {log.card.name}
                </span>
              </td>
              <td className="px-6 py-4 text-[15px] text-[#4E5968] font-medium">
                &quot;{log.voice}&quot;
              </td>
              <td className="px-6 py-4 text-right">
                <span className="text-[13px] font-bold text-green-600 bg-green-50 px-2.5 py-1 rounded-md">수신됨</span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
