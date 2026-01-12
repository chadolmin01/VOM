'use client';

import { useRef } from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  ArcElement,
} from 'chart.js';
import { Line, Doughnut } from 'react-chartjs-2';

// Chart.js 등록
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  ArcElement
);

// 라인 차트 데이터
const lineChartData = {
  labels: ['월', '화', '수', '목', '금', '토', '일'],
  datasets: [
    {
      label: '참여 가정',
      data: [12, 19, 25, 30, 42, 38, 45],
      borderColor: '#3182F6',
      backgroundColor: (context: { chart: ChartJS }) => {
        const ctx = context.chart.ctx;
        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(49, 130, 246, 0.15)');
        gradient.addColorStop(1, 'rgba(49, 130, 246, 0)');
        return gradient;
      },
      borderWidth: 2,
      pointBackgroundColor: '#FFFFFF',
      pointBorderColor: '#3182F6',
      pointBorderWidth: 2,
      pointRadius: 4,
      pointHoverRadius: 6,
      tension: 0.4,
      fill: true,
    },
  ],
};

const lineChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: '#1B1D25',
      padding: 12,
      cornerRadius: 4,
      displayColors: false,
    },
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: { color: '#8B95A1', font: { family: 'Pretendard' } },
    },
    y: {
      grid: {
        color: '#E5E8EB',
      },
      ticks: { color: '#8B95A1', font: { family: 'Pretendard' } },
      beginAtZero: true,
    },
  },
};

const doughnutChartData = {
  labels: ['따라 말하기', '단순 시청'],
  datasets: [
    {
      data: [72, 28],
      backgroundColor: ['#3182F6', '#E5E8EB'],
      borderWidth: 0,
      hoverOffset: 4,
    },
  ],
};

const doughnutChartOptions = {
  cutout: '80%',
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
  },
};

interface ChartsProps {
  period?: string;
}

export default function Charts({ period }: ChartsProps) {
  const chartRef = useRef<ChartJS<'line'>>(null);

  return (
    <div className="grid grid-cols-12 gap-6">
      {/* Main Line Chart */}
      <div className="col-span-8 bg-white p-7 rounded-[18px] border border-gray-200 shadow-[0_2px_8px_rgba(0,0,0,0.04)]">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-[19px] font-bold text-[#191F28]">주간 학습 참여 추이</h3>
          <div className="flex gap-2">
            <select className="text-[15px] font-medium text-[#4E5968] bg-[#F9FAFB] border border-[#E5E8EB] rounded-[6px] px-3 py-1.5 outline-none">
              <option>최근 7일</option>
              <option>최근 30일</option>
            </select>
          </div>
        </div>
        <div className="h-[300px] w-full">
          <Line ref={chartRef} data={lineChartData} options={lineChartOptions} />
        </div>
      </div>

      {/* Side Doughnut Chart */}
      <div className="col-span-4 bg-white p-7 rounded-[18px] border border-gray-200 shadow-[0_2px_8px_rgba(0,0,0,0.04)] flex flex-col">
        <h3 className="text-[19px] font-bold text-[#191F28] mb-6">학습 유형 분석</h3>
        <div className="flex-1 flex items-center justify-center relative">
          <div className="w-[220px] h-[220px]">
            <Doughnut data={doughnutChartData} options={doughnutChartOptions} />
          </div>
          <div className="absolute inset-0 flex items-center justify-center flex-col pointer-events-none">
            <span className="text-[44px] font-extrabold text-[#191F28]">72%</span>
            <span className="text-[13px] font-bold text-[#8B95A1] mt-1">참여형 학습</span>
          </div>
        </div>
        <div className="flex gap-2 mt-4">
          <div className="flex-1 p-3 bg-[#F9FAFB] rounded-[8px] text-center">
            <div className="text-[13px] text-[#8B95A1]">따라하기</div>
            <div className="font-bold text-[#3182F6] text-[15px]">72%</div>
          </div>
          <div className="flex-1 p-3 bg-[#F9FAFB] rounded-[8px] text-center">
            <div className="text-[13px] text-[#8B95A1]">듣기</div>
            <div className="font-bold text-[#6B7684] text-[15px]">28%</div>
          </div>
        </div>
      </div>
    </div>
  );
}
