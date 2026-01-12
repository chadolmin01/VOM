'use client';

import { useState, useEffect } from 'react';
import { LogEntry, TabType } from '@/types';
import { FONT_STYLE, SAMPLE_USERS, SAMPLE_CARDS, SAMPLE_VOICES } from '@/constants';

// Components
import LoginScreen from '@/components/LoginScreen';
import Sidebar from '@/components/layout/Sidebar';
import Header from '@/components/layout/Header';

// Dashboard Tabs
import { OverviewTab, LiveMonitorTab } from '@/components/tabs/dashboard';

// Users Tabs
import { UsersListTab, UsersGroupTab } from '@/components/tabs/users';

// Data Tabs
import { VoiceDataTab, ReportTab, DeviceTab } from '@/components/tabs/data';

// Operation Tabs
import { NoticeTab, ContentTab } from '@/components/tabs/operation';

// Settings Tabs
import { AdminAccountTab, EnvironmentTab } from '@/components/tabs/settings';

// Widgets
import { MessengerWidget } from '@/components/widgets';

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState<TabType>('dashboard_overview');
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  // 탭 변경 시 모바일에서 사이드바 닫기
  const handleTabChange = (tab: TabType) => {
    setActiveTab(tab);
    setIsSidebarOpen(false);
  };

  // 실시간 로그 시뮬레이션
  useEffect(() => {
    if (!isLoggedIn) return;

    const addLog = () => {
      const newLog: LogEntry = {
        id: Date.now().toString(),
        time: new Date().toLocaleTimeString('ko-KR', {
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit',
        }),
        user: SAMPLE_USERS[Math.floor(Math.random() * SAMPLE_USERS.length)],
        card: SAMPLE_CARDS[Math.floor(Math.random() * SAMPLE_CARDS.length)],
        voice: SAMPLE_VOICES[Math.floor(Math.random() * SAMPLE_VOICES.length)],
        status: 'received',
      };
      setLogs((prev) => [newLog, ...prev].slice(0, 10));
    };

    addLog();
    setTimeout(addLog, 100);
    setTimeout(addLog, 200);

    const interval = setInterval(addLog, 3000);
    return () => clearInterval(interval);
  }, [isLoggedIn]);

  const handleLogin = () => setIsLoggedIn(true);
  const handleLogout = () => setIsLoggedIn(false);

  // 탭 렌더링 함수
  const renderTabContent = () => {
    switch (activeTab) {
      // Dashboard
      case 'dashboard_overview':
        return <OverviewTab logs={logs} />;
      case 'dashboard_live':
        return <LiveMonitorTab logs={logs} />;

      // Users
      case 'users_list':
        return <UsersListTab />;
      case 'users_group':
        return <UsersGroupTab />;

      // Data
      case 'data_voice':
        return <VoiceDataTab />;
      case 'data_report':
        return <ReportTab />;
      case 'data_device':
        return <DeviceTab />;

      // Operation
      case 'op_notice':
        return <NoticeTab />;
      case 'op_content':
        return <ContentTab />;

      // Settings
      case 'set_admin':
        return <AdminAccountTab />;
      case 'set_env':
        return <EnvironmentTab onLogout={handleLogout} />;

      default:
        return <OverviewTab logs={logs} />;
    }
  };

  // 로그인 전 화면
  if (!isLoggedIn) {
    return <LoginScreen onLogin={handleLogin} />;
  }

  // 로그인 후 대시보드
  return (
    <div className="flex h-screen bg-[#F2F4F6]" style={FONT_STYLE}>
      <Sidebar
        activeTab={activeTab}
        onTabChange={handleTabChange}
        onLogout={handleLogout}
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
      />

      <main className="flex-1 flex flex-col min-w-0 overflow-hidden bg-[#F2F4F6]">
        <Header
          activeTab={activeTab}
          onMenuClick={() => setIsSidebarOpen(true)}
        />

        <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 md:p-8 scroll-smooth">
          <div className="w-full space-y-6">
            {renderTabContent()}
          </div>
        </div>
      </main>

      {/* 우하단 메신저 위젯 */}
      <MessengerWidget />
    </div>
  );
}
