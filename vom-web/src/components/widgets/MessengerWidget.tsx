'use client';

import { useState } from 'react';

interface Message {
  id: string;
  sender: string;
  content: string;
  time: string;
  isRead: boolean;
  avatar?: string;
}

const SAMPLE_MESSAGES: Message[] = [
  { id: '1', sender: '김민지 담당자', content: '안녕하세요, 학습 데이터 관련 문의드립니다.', time: '10:32', isRead: false },
  { id: '2', sender: '박서준 센터장', content: '금일 회의 자료 확인 부탁드립니다.', time: '09:15', isRead: false },
  { id: '3', sender: '시스템 알림', content: '새로운 대상자 3명이 등록되었습니다.', time: '어제', isRead: true },
  { id: '4', sender: '이수현 담당자', content: '리포트 검토 완료했습니다. 감사합니다!', time: '어제', isRead: true },
];

export default function MessengerWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<'messages' | 'notifications'>('messages');
  const [messages] = useState<Message[]>(SAMPLE_MESSAGES);

  const unreadCount = messages.filter(m => !m.isRead).length;

  return (
    <>
      {/* 플로팅 버튼 */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`fixed bottom-6 right-6 w-14 h-14 rounded-full shadow-lg flex items-center justify-center transition-all duration-300 z-50 ${
          isOpen ? 'bg-[#191F28] rotate-90' : 'bg-[#3182F6] hover:bg-[#1B64DA] hover:scale-105'
        }`}
      >
        {isOpen ? (
          <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        ) : (
          <>
            <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white text-[11px] font-bold rounded-full flex items-center justify-center animate-pulse">
                {unreadCount}
              </span>
            )}
          </>
        )}
      </button>

      {/* 메신저 패널 */}
      <div className={`fixed bottom-24 right-6 w-[360px] bg-white rounded-[20px] shadow-2xl border border-gray-100 overflow-hidden z-50 transition-all duration-300 ${
        isOpen ? 'opacity-100 translate-y-0 pointer-events-auto' : 'opacity-0 translate-y-4 pointer-events-none'
      }`}>
        {/* 헤더 */}
        <div className="bg-gradient-to-r from-[#3182F6] to-[#60A5FA] p-5">
          <h3 className="text-[17px] font-bold text-white">메시지 센터</h3>
          <p className="text-[13px] text-white/80 mt-0.5">읽지 않은 메시지 {unreadCount}개</p>
        </div>

        {/* 탭 */}
        <div className="flex border-b border-gray-100">
          <button
            onClick={() => setActiveTab('messages')}
            className={`flex-1 py-3 text-[14px] font-bold transition-colors ${
              activeTab === 'messages' ? 'text-[#3182F6] border-b-2 border-[#3182F6]' : 'text-gray-400'
            }`}
          >
            쪽지함
          </button>
          <button
            onClick={() => setActiveTab('notifications')}
            className={`flex-1 py-3 text-[14px] font-bold transition-colors ${
              activeTab === 'notifications' ? 'text-[#3182F6] border-b-2 border-[#3182F6]' : 'text-gray-400'
            }`}
          >
            알림
          </button>
        </div>

        {/* 메시지 리스트 */}
        <div className="max-h-[320px] overflow-y-auto">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex items-start gap-3 p-4 border-b border-gray-50 hover:bg-gray-50 cursor-pointer transition-colors ${
                !msg.isRead ? 'bg-blue-50/30' : ''
              }`}
            >
              {/* 아바타 */}
              <div className={`w-10 h-10 rounded-full flex items-center justify-center text-[14px] font-bold shrink-0 ${
                msg.sender.includes('시스템') ? 'bg-gray-100 text-gray-500' : 'bg-[#E8F3FF] text-[#3182F6]'
              }`}>
                {msg.sender.includes('시스템') ? (
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                  </svg>
                ) : (
                  msg.sender[0]
                )}
              </div>

              {/* 내용 */}
              <div className="flex-1 min-w-0">
                <div className="flex justify-between items-center mb-1">
                  <span className={`text-[14px] font-bold ${!msg.isRead ? 'text-[#191F28]' : 'text-gray-600'}`}>
                    {msg.sender}
                  </span>
                  <span className="text-[12px] text-gray-400">{msg.time}</span>
                </div>
                <p className={`text-[13px] truncate ${!msg.isRead ? 'text-[#4E5968] font-medium' : 'text-gray-400'}`}>
                  {msg.content}
                </p>
              </div>

              {/* 읽지 않음 표시 */}
              {!msg.isRead && (
                <div className="w-2 h-2 bg-[#3182F6] rounded-full shrink-0 mt-2"></div>
              )}
            </div>
          ))}
        </div>

        {/* 하단 버튼 */}
        <div className="p-4 border-t border-gray-100">
          <button className="w-full py-3 bg-[#F2F4F6] hover:bg-[#E5E8EB] rounded-xl text-[14px] font-bold text-[#4E5968] transition-colors">
            새 메시지 작성
          </button>
        </div>
      </div>
    </>
  );
}
