'use client';

import { LogEntry } from '@/types';
import KPICards from './KPICards';
import Charts from './Charts';
import ActivityLog from './ActivityLog';

interface DashboardTabProps {
  logs: LogEntry[];
}

export default function DashboardTab({ logs }: DashboardTabProps) {
  return (
    <div className="animate-fade-in space-y-6">
      <KPICards />
      <Charts />
      <ActivityLog logs={logs} />
    </div>
  );
}
