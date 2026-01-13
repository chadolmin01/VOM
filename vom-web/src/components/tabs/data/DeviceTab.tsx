'use client';

import { useState, useEffect } from 'react';
import {
  fetchMappings,
  fetchCardContents,
  createMapping,
  deleteMapping,
  NfcCardMapping,
  CardContent
} from '@/lib/supabase';

export default function DeviceTab() {
  const [mappings, setMappings] = useState<NfcCardMapping[]>([]);
  const [cardContents, setCardContents] = useState<CardContent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);

  // 새 매핑 폼
  const [newMapping, setNewMapping] = useState({
    nfc_tag_id: '',
    qr_code: '',
    card_id: '',
    label: '',
  });

  useEffect(() => {
    loadData();
    
    // 실시간 구독: nfc_card_mappings 테이블 변경 감지
    const channel = supabase
      .channel('nfc_mappings_realtime')
      .on(
        'postgres_changes',
        {
          event: '*', // INSERT, UPDATE, DELETE 모두 감지
          schema: 'public',
          table: 'nfc_card_mappings',
        },
        (payload) => {
          console.log('NFC 매핑 변경 감지:', payload);
          // 변경 사항이 있으면 데이터 다시 불러오기
          loadData();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [mappingsData, contentsData] = await Promise.all([
        fetchMappings(),
        fetchCardContents(),
      ]);
      setMappings(mappingsData);
      setCardContents(contentsData);
    } catch (error) {
      console.error('데이터 로드 실패:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreate = async () => {
    if (!newMapping.card_id) {
      alert('카드 콘텐츠를 선택해주세요.');
      return;
    }
    if (!newMapping.nfc_tag_id && !newMapping.qr_code) {
      alert('NFC 태그 ID 또는 QR 코드를 입력해주세요.');
      return;
    }

    const success = await createMapping({
      nfc_tag_id: newMapping.nfc_tag_id || undefined,
      qr_code: newMapping.qr_code || undefined,
      card_id: newMapping.card_id,
      label: newMapping.label || undefined,
    });

    if (success) {
      setShowModal(false);
      setNewMapping({ nfc_tag_id: '', qr_code: '', card_id: '', label: '' });
      loadData();
    } else {
      alert('매핑 생성에 실패했습니다.');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('정말 삭제하시겠습니까?')) return;

    const success = await deleteMapping(id);
    if (success) {
      loadData();
    } else {
      alert('삭제에 실패했습니다.');
    }
  };

  const nfcCount = mappings.filter(m => m.nfc_tag_id).length;
  const qrCount = mappings.filter(m => m.qr_code).length;

  return (
    <div className="space-y-4 md:space-y-6">
      {/* 상단 통계 */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
        <div className="bg-white rounded-[14px] md:rounded-[18px] border border-gray-200 p-4 md:p-6 shadow-sm">
          <div className="flex items-center gap-2 md:gap-3 mb-2 md:mb-3">
            <div className="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-blue-50 flex items-center justify-center">
              <svg className="w-4 h-4 md:w-5 md:h-5 text-[#3182F6]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" />
              </svg>
            </div>
            <span className="text-[13px] md:text-[15px] font-bold text-gray-500">전체 매핑</span>
          </div>
          <p className="text-[28px] md:text-[36px] font-extrabold text-[#191F28]">{mappings.length}</p>
        </div>
        <div className="bg-white rounded-[14px] md:rounded-[18px] border border-gray-200 p-4 md:p-6 shadow-sm">
          <div className="flex items-center gap-2 md:gap-3 mb-2 md:mb-3">
            <div className="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-purple-50 flex items-center justify-center">
              <span className="text-lg md:text-xl">📡</span>
            </div>
            <span className="text-[13px] md:text-[15px] font-bold text-gray-500">NFC 태그</span>
          </div>
          <p className="text-[28px] md:text-[36px] font-extrabold text-purple-600">{nfcCount}</p>
        </div>
        <div className="bg-white rounded-[14px] md:rounded-[18px] border border-gray-200 p-4 md:p-6 shadow-sm">
          <div className="flex items-center gap-2 md:gap-3 mb-2 md:mb-3">
            <div className="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-green-50 flex items-center justify-center">
              <span className="text-lg md:text-xl">📱</span>
            </div>
            <span className="text-[13px] md:text-[15px] font-bold text-gray-500">QR 코드</span>
          </div>
          <p className="text-[28px] md:text-[36px] font-extrabold text-green-600">{qrCount}</p>
        </div>
        <div className="bg-white rounded-[14px] md:rounded-[18px] border border-gray-200 p-4 md:p-6 shadow-sm">
          <div className="flex items-center gap-2 md:gap-3 mb-2 md:mb-3">
            <div className="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-orange-50 flex items-center justify-center">
              <span className="text-lg md:text-xl">📦</span>
            </div>
            <span className="text-[13px] md:text-[15px] font-bold text-gray-500">콘텐츠 수</span>
          </div>
          <p className="text-[28px] md:text-[36px] font-extrabold text-orange-600">{cardContents.length}</p>
        </div>
      </div>

      {/* 매핑 목록 */}
      <div className="bg-white rounded-[14px] md:rounded-[18px] border border-gray-200 shadow-sm overflow-hidden">
        <div className="px-4 md:px-6 py-4 md:py-5 border-b border-gray-100 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
          <div>
            <h3 className="text-[15px] md:text-[17px] font-bold text-[#191F28]">NFC/QR 매핑 관리</h3>
            <p className="text-[12px] md:text-[13px] text-gray-400 mt-0.5">태그 UID와 학습 카드를 연결합니다</p>
          </div>
          <div className="flex gap-2 w-full sm:w-auto">
            <button
              onClick={loadData}
              className="flex-1 sm:flex-none px-4 py-3 border border-gray-200 rounded-xl text-[14px] font-bold text-gray-600 hover:bg-gray-50 transition-colors min-h-[44px]"
            >
              새로고침
            </button>
            <button
              onClick={() => setShowModal(true)}
              className="flex-1 sm:flex-none px-4 py-3 bg-[#3182F6] text-white rounded-xl text-[14px] font-bold hover:bg-[#1B64DA] transition-colors min-h-[44px]"
            >
              + 매핑 추가
            </button>
          </div>
        </div>

        {isLoading ? (
          <div className="p-8 md:p-12 text-center text-gray-400">
            <div className="animate-spin w-8 h-8 border-2 border-[#3182F6] border-t-transparent rounded-full mx-auto mb-3"></div>
            데이터를 불러오는 중...
          </div>
        ) : mappings.length === 0 ? (
          <div className="p-8 md:p-12 text-center text-gray-400">
            <span className="text-4xl mb-3 block">📡</span>
            등록된 매핑이 없습니다.<br />
            <span className="text-[12px] md:text-[13px]">Flutter Admin 앱에서 NFC 태그를 스캔하여 등록하거나,<br />위 버튼을 눌러 수동으로 추가하세요.</span>
          </div>
        ) : (
          <>
            {/* 모바일: 카드 형태 */}
            <div className="md:hidden divide-y divide-gray-100">
              {mappings.map((mapping) => (
                <div key={mapping.id} className="p-4">
                  <div className="flex items-center justify-between mb-3">
                    <span className={`px-3 py-1.5 rounded-lg text-[13px] font-bold ${
                      mapping.nfc_tag_id
                        ? 'bg-purple-50 text-purple-600'
                        : 'bg-green-50 text-green-600'
                    }`}>
                      {mapping.nfc_tag_id ? '📡 NFC' : '📱 QR'}
                    </span>
                    <span className="text-[13px] text-gray-400">
                      {new Date(mapping.created_at).toLocaleDateString('ko-KR')}
                    </span>
                  </div>

                  <div className="mb-3">
                    <p className="text-[12px] text-gray-400 mb-1">태그 ID / QR</p>
                    <code className="text-[13px] font-mono bg-gray-100 px-2 py-1 rounded text-gray-700 break-all">
                      {mapping.nfc_tag_id || mapping.qr_code}
                    </code>
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="text-lg">{mapping.card_contents?.icon || '📦'}</span>
                      <span className="text-[14px] font-bold text-[#191F28]">
                        {mapping.card_contents?.name || mapping.card_id}
                      </span>
                      {mapping.label && (
                        <span className="text-[12px] text-gray-400">({mapping.label})</span>
                      )}
                    </div>
                    <button
                      onClick={() => handleDelete(mapping.id)}
                      className="px-4 py-2 text-red-500 text-[14px] font-bold hover:bg-red-50 rounded-lg min-h-[44px]"
                    >
                      삭제
                    </button>
                  </div>
                </div>
              ))}
            </div>

            {/* 데스크탑: 테이블 형태 */}
            <table className="hidden md:table w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">유형</th>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">태그 ID / QR</th>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">연결된 콘텐츠</th>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">라벨</th>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">등록일</th>
                  <th className="px-6 py-3.5 text-left text-[13px] font-bold text-gray-500">관리</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {mappings.map((mapping) => (
                  <tr key={mapping.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <span className={`px-3 py-1.5 rounded-lg text-[13px] font-bold ${
                        mapping.nfc_tag_id
                          ? 'bg-purple-50 text-purple-600'
                          : 'bg-green-50 text-green-600'
                      }`}>
                        {mapping.nfc_tag_id ? '📡 NFC' : '📱 QR'}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <code className="text-[14px] font-mono bg-gray-100 px-2 py-1 rounded text-gray-700">
                        {mapping.nfc_tag_id || mapping.qr_code}
                      </code>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <span className="text-xl">{mapping.card_contents?.icon || '📦'}</span>
                        <span className="text-[15px] font-bold text-[#191F28]">
                          {mapping.card_contents?.name || mapping.card_id}
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-[14px] text-gray-500">
                      {mapping.label || '-'}
                    </td>
                    <td className="px-6 py-4 text-[14px] text-gray-500">
                      {new Date(mapping.created_at).toLocaleDateString('ko-KR')}
                    </td>
                    <td className="px-6 py-4">
                      <button
                        onClick={() => handleDelete(mapping.id)}
                        className="px-4 py-2 text-red-500 text-[14px] font-bold hover:bg-red-50 rounded-lg min-h-[36px]"
                      >
                        삭제
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}
      </div>

      {/* 추가 모달 */}
      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4">
          <div className="bg-white rounded-t-[20px] sm:rounded-[20px] p-6 md:p-8 w-full sm:max-w-md shadow-2xl max-h-[90vh] overflow-y-auto">
            <h3 className="text-[19px] font-bold text-[#191F28] mb-6">새 매핑 추가</h3>

            <div className="space-y-4">
              <div>
                <label className="block text-[13px] font-bold text-gray-500 mb-2">NFC 태그 ID</label>
                <input
                  type="text"
                  placeholder="예: 04:A2:B3:C4:D5:E6:F7"
                  value={newMapping.nfc_tag_id}
                  onChange={(e) => setNewMapping({ ...newMapping, nfc_tag_id: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl text-[15px] outline-none focus:ring-2 focus:ring-[#3182F6] border border-transparent"
                />
              </div>

              <div className="text-center text-[13px] text-gray-400">또는</div>

              <div>
                <label className="block text-[13px] font-bold text-gray-500 mb-2">QR 코드 값</label>
                <input
                  type="text"
                  placeholder="예: VOM-CARD-001"
                  value={newMapping.qr_code}
                  onChange={(e) => setNewMapping({ ...newMapping, qr_code: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl text-[15px] outline-none focus:ring-2 focus:ring-[#3182F6] border border-transparent"
                />
              </div>

              <div>
                <label className="block text-[13px] font-bold text-gray-500 mb-2">연결할 콘텐츠 *</label>
                <select
                  value={newMapping.card_id}
                  onChange={(e) => setNewMapping({ ...newMapping, card_id: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl text-[15px] outline-none focus:ring-2 focus:ring-[#3182F6] border border-transparent"
                >
                  <option value="">선택하세요</option>
                  {cardContents.map((card) => (
                    <option key={card.id} value={card.id}>
                      {card.icon} {card.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-[13px] font-bold text-gray-500 mb-2">라벨 (선택)</label>
                <input
                  type="text"
                  placeholder="예: 서울센터-체온계-01"
                  value={newMapping.label}
                  onChange={(e) => setNewMapping({ ...newMapping, label: e.target.value })}
                  className="w-full px-4 py-3 bg-gray-50 rounded-xl text-[15px] outline-none focus:ring-2 focus:ring-[#3182F6] border border-transparent"
                />
              </div>
            </div>

            <div className="flex gap-3 mt-8">
              <button
                onClick={() => setShowModal(false)}
                className="flex-1 py-3 border border-gray-200 rounded-xl text-[15px] font-bold text-gray-500 hover:bg-gray-50 transition-colors min-h-[48px]"
              >
                취소
              </button>
              <button
                onClick={handleCreate}
                className="flex-1 py-3 bg-[#3182F6] text-white rounded-xl text-[15px] font-bold hover:bg-[#1B64DA] transition-colors min-h-[48px]"
              >
                추가
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
