// 샘플 데이터 & 상수
export const SAMPLE_USERS = [
  '김*미 (다문화)',
  '이*진 (한부모)',
  '박*수 (경계선)',
  '최*영',
  'Nguyen (다문화)'
];

export const SAMPLE_CARDS = [
  { name: '체온계', type: '응급', bgColor: 'bg-red-50', textColor: 'text-red-600' },
  { name: '양치질', type: '위생', bgColor: 'bg-blue-50', textColor: 'text-blue-600' },
  { name: '동화책', type: '정서', bgColor: 'bg-purple-50', textColor: 'text-purple-600' },
  { name: '손씻기', type: '위생', bgColor: 'bg-green-50', textColor: 'text-green-600' },
];

export const SAMPLE_VOICES = [
  '애가.. 아파요..',
  '치카치카..',
  '사랑해..',
  '엄마가.. 해줄게..',
  '(주변 소음 감지)'
];

export const KPI_DATA = [
  { title: '금일 실시간 접속', value: '42', unit: '명', change: '+12%', isUp: true },
  { title: '누적 발화 데이터', value: '1,256', unit: '건', change: '+84건', isUp: true },
  { title: '장기 미접속 가정', value: '5', unit: '가구', change: '관리 요망', isUp: false, alert: true },
  { title: '긴급 키워드 감지', value: '2', unit: '건', change: '즉시 확인', isUp: false, alert: true },
];

export const FONT_STYLE = {
  fontFamily: '"Pretendard", -apple-system, BlinkMacSystemFont, system-ui, Roboto, sans-serif'
};
