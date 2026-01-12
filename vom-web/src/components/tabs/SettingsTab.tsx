'use client';

interface SettingsTabProps {
  onLogout: () => void;
}

export default function SettingsTab({ onLogout }: SettingsTabProps) {
  return (
    <div className="bg-white border border-gray-200 rounded-[16px] shadow-sm p-8">
      <h3 className="text-lg font-bold text-[#191F28] mb-6">설정</h3>
      <button
        onClick={onLogout}
        className="px-6 py-3 bg-red-500 text-white font-bold rounded-[8px] hover:bg-red-600"
      >
        로그아웃
      </button>
    </div>
  );
}
