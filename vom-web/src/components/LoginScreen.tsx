'use client';

import { useState } from 'react';

const TEXTS = {
  KO: {
    welcome: "로그인", // 더 간결하게 변경
    desc: "관리자 계정으로 접속하세요.",
    idPlaceholder: "아이디",
    pwPlaceholder: "비밀번호",
    loginBtn: "로그인",
    saveId: "아이디 저장",
    typeLabel: "기관 유형",
    center: "지역 센터",
    gov: "협력 기관",
    tabCenter: "센터 담당자",
    tabAdmin: "관리기관",
    adminCode: "인증 코드",
    adminCodePlace: "Master Key",
    findInfo: "계정 찾기"
  },
  EN: {
    welcome: "Sign In",
    desc: "Welcome back, Admin.",
    idPlaceholder: "ID",
    pwPlaceholder: "Password",
    loginBtn: "Sign In",
    saveId: "Remember ID",
    typeLabel: "Org Type",
    center: "Local Center",
    gov: "Partner Org",
    tabCenter: "Center Manager",
    tabAdmin: "System Admin",
    adminCode: "Auth Code",
    adminCodePlace: "Master Key",
    findInfo: "Find Account"
  }
};

interface LoginScreenProps {
  onLogin: () => void;
}

export default function LoginScreen({ onLogin }: LoginScreenProps) {
  const [loginId, setLoginId] = useState('admin');
  const [loginPw, setLoginPw] = useState('1234');
  const [adminCode, setAdminCode] = useState('');
  
  const [loginType, setLoginType] = useState<'center' | 'admin'>('center');
  const [userType, setUserType] = useState<'multicultural' | 'government'>('multicultural');
  const [saveId, setSaveId] = useState(false);
  
  const [lang, setLang] = useState<'KO' | 'EN'>('KO');
  const [isLangOpen, setIsLangOpen] = useState(false);

  const t = TEXTS[lang];

  const handleLogin = () => {
    if (loginId && loginPw) {
      onLogin();
    }
  };

  return (
    <div className="flex h-screen w-full overflow-hidden bg-white font-pretendard">
      <style jsx global>{`
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.8/dist/web/static/pretendard.css");
        .font-pretendard { font-family: "Pretendard", -apple-system, BlinkMacSystemFont, system-ui, Roboto, sans-serif; }

        @keyframes blob {
          0% { transform: translate(0px, 0px) scale(1); }
          33% { transform: translate(30px, -50px) scale(1.1); }
          66% { transform: translate(-20px, 20px) scale(0.9); }
          100% { transform: translate(0px, 0px) scale(1); }
        }
        @keyframes float-screen {
          0% { transform: perspective(1000px) rotateY(-12deg) rotateX(2deg) translateY(0px); }
          50% { transform: perspective(1000px) rotateY(-12deg) rotateX(2deg) translateY(-15px); }
          100% { transform: perspective(1000px) rotateY(-12deg) rotateX(2deg) translateY(0px); }
        }
        @keyframes slide-up { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes dash { to { stroke-dashoffset: 0; } }

        .animate-blob { animation: blob 10s infinite; }
        .animate-float-screen { animation: float-screen 8s ease-in-out infinite; }
        .animate-slide-up { animation: slide-up 0.4s ease-out forwards; }
        .delay-2000 { animation-delay: 2s; }
        
        .pie-chart { background: conic-gradient(#3182F6 0% 65%, #E5E7EB 65% 100%); border-radius: 50%; }
        .path-anim { stroke-dasharray: 1000; stroke-dashoffset: 1000; animation: dash 3s linear forwards; }
      `}</style>

      {/* 🌑 [왼쪽 80%] 그래픽 영역 (그래픽 위치 조정됨: right-[-18%]) */}
      <div className="hidden lg:flex w-[80%] bg-[#0F1117] relative flex-col justify-between p-16 overflow-hidden">
        
        {/* 배경 오로라 */}
        <div className="absolute inset-0 w-full h-full pointer-events-none">
          <div className="absolute top-[-20%] left-[-10%] w-[1200px] h-[1200px] bg-[#3182F6] rounded-full mix-blend-screen filter blur-[150px] opacity-15 animate-blob"></div>
          <div className="absolute bottom-[-10%] right-[20%] w-[1000px] h-[1000px] bg-purple-600 rounded-full mix-blend-screen filter blur-[150px] opacity-15 animate-blob delay-2000"></div>
        </div>

        {/* 텍스트 (글자 크기 미세 조정으로 겹침 방지) */}
        <div className="relative z-10 max-w-2xl">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 bg-[#3182F6] rounded-[12px] flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-blue-500/30">V</div>
            <span className="text-white font-bold text-lg tracking-wide opacity-90">V.O.M Admin</span>
          </div>
          <h1 className="text-6xl font-extrabold text-white leading-[1.1] mb-6 tracking-tight">
            Smart Care for<br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#3182F6] to-[#60A5FA]">Slow Learners.</span>
          </h1>
          <p className="text-gray-400 text-xl leading-relaxed font-medium">
            경계선 지능 및 느린 학습자 부모를 위한<br />
            쉬운 육아 코칭 솔루션, <span className="text-white font-bold">V.O.M</span>
          </p>
        </div>

        {/* 🖥️ 3D 대시보드 그래픽 (오른쪽으로 더 이동하여 겹침 해결) */}
        <div className="absolute right-[-18%] top-[18%] w-[85%] h-[85%] z-0 animate-float-screen">
          <div className="absolute top-[-20px] left-[40px] w-full h-full bg-white/5 rounded-[40px] border border-white/5 backdrop-blur-sm transform scale-95"></div>

          <div className="w-full h-full bg-[#F2F4F6] rounded-tl-[40px] rounded-bl-[40px] shadow-[0_50px_100px_-20px_rgba(0,0,0,0.5)] border-l border-t border-white/20 p-6 flex gap-6 overflow-hidden relative opacity-95">
            {/* Sidebar */}
            <div className="w-64 bg-white rounded-[28px] shadow-sm flex flex-col p-6 shrink-0">
               <div className="flex items-center gap-3 mb-10">
                  <div className="w-10 h-10 bg-[#3182F6] rounded-xl shadow-blue-200"></div>
                  <div className="h-4 w-24 bg-gray-100 rounded"></div>
               </div>
               <div className="space-y-4">
                  <div className="h-10 w-full bg-blue-50 rounded-xl border-l-4 border-blue-500 flex items-center px-4"><div className="w-20 h-2 bg-blue-200 rounded"></div></div>
                  <div className="h-10 w-full bg-white rounded-xl flex items-center px-4"><div className="w-16 h-2 bg-gray-100 rounded"></div></div>
                  <div className="h-10 w-full bg-white rounded-xl flex items-center px-4"><div className="w-24 h-2 bg-gray-100 rounded"></div></div>
               </div>
            </div>

            {/* Content */}
            <div className="flex-1 flex flex-col gap-6">
               <div className="h-16 flex justify-between items-center px-2">
                  <div className="space-y-2"><div className="h-5 w-40 bg-gray-800 rounded"></div><div className="h-2 w-24 bg-gray-400 rounded"></div></div>
                  <div className="flex gap-3"><div className="h-10 w-24 bg-white rounded-xl shadow-sm"></div><div className="h-10 w-10 bg-white rounded-full shadow-sm"></div></div>
               </div>
               
               <div className="grid grid-cols-3 gap-5">
                  {[...Array(3)].map((_, i) => (
                     <div key={i} className="bg-white p-5 rounded-[24px] shadow-sm flex flex-col justify-between h-28">
                        <div className="flex justify-between items-start"><div className="h-2 w-12 bg-gray-100 rounded"></div><div className={`w-6 h-6 rounded-full ${i===0 ? 'bg-blue-100' : 'bg-gray-50'}`}></div></div>
                        <div className="h-6 w-16 bg-gray-800 rounded"></div>
                     </div>
                  ))}
               </div>

               <div className="flex gap-5 h-64">
                  <div className="flex-[2] bg-white rounded-[28px] shadow-sm p-6 relative overflow-hidden flex flex-col">
                     <div className="flex-1 relative">
                        <svg className="w-full h-full overflow-visible" preserveAspectRatio="none">
                           <path d="M0,100 Q50,20 100,50 T200,80 T300,30 T400,60 T500,10" fill="none" stroke="#3182F6" strokeWidth="4" className="path-anim" />
                           <path d="M0,100 Q50,20 100,50 T200,80 T300,30 T400,60 T500,10 V150 H0 Z" fill="url(#gradient)" opacity="0.1" />
                           <defs><linearGradient id="gradient" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stopColor="#3182F6" /><stop offset="100%" stopColor="white" /></linearGradient></defs>
                        </svg>
                     </div>
                  </div>
                  <div className="flex-1 bg-white rounded-[28px] shadow-sm p-6 flex flex-col items-center justify-center relative">
                     <div className="w-24 h-24 pie-chart relative"><div className="absolute inset-3 bg-white rounded-full flex items-center justify-center"><span className="text-sm font-bold text-gray-800">65%</span></div></div>
                  </div>
               </div>
               <div className="h-32 bg-white rounded-[28px] shadow-sm p-6 flex flex-col justify-end">
                  <div className="flex items-end justify-between gap-3 h-full px-2">
                     {[40, 70, 50, 85, 60, 90, 65, 45, 80, 55, 75, 95].map((h, i) => (
                        <div key={i} className="w-full bg-blue-50 rounded-t-md relative h-full"><div className="absolute bottom-0 w-full bg-[#3182F6] rounded-t-md opacity-80" style={{ height: `${h}%` }}></div></div>
                     ))}
                  </div>
               </div>
            </div>
            <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/5 to-white/30 pointer-events-none rounded-tl-[40px]"></div>
          </div>
        </div>
      </div>

      {/* 🔐 [오른쪽 20%] 로그인 폼 (컴팩트하게 조정) */}
      <div className="flex-1 flex flex-col bg-white border-l border-gray-100 shadow-2xl z-20 relative">
        
        {/* 언어 선택 */}
        <div className="flex justify-end p-5">
           <div className="relative">
              <button 
                onClick={() => setIsLangOpen(!isLangOpen)}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <span className="text-base">🌐</span>
                <span className="text-xs font-bold text-gray-500">{lang}</span>
              </button>
              {isLangOpen && (
                <div className="absolute right-0 mt-1 w-20 bg-white rounded-lg shadow-lg border border-gray-100 py-1 z-30 overflow-hidden animate-slide-up">
                  <button onClick={() => {setLang('KO'); setIsLangOpen(false)}} className="w-full text-center py-2 text-xs font-bold hover:bg-gray-50 text-gray-600">KO</button>
                  <button onClick={() => {setLang('EN'); setIsLangOpen(false)}} className="w-full text-center py-2 text-xs font-bold hover:bg-gray-50 text-gray-600">EN</button>
                </div>
              )}
           </div>
        </div>

        {/* 폼 컨텐츠 (입력창과 버튼 사이즈 축소) */}
        <div className="flex-1 flex flex-col justify-center px-6 sm:px-8 pb-8">
          <div className="mb-6">
            <h2 className="text-2xl font-extrabold text-[#191F28] mb-1">{t.welcome}</h2>
            <p className="text-sm text-[#8B95A1] font-medium">
              {t.desc}
            </p>
          </div>

          <div className="space-y-3 w-full">
            {/* 탭: 모드 변경 (조금 더 작게) */}
            <div className="bg-[#F2F4F6] p-1 rounded-lg flex w-full">
              <button onClick={() => setLoginType('center')} className={`flex-1 py-2 text-[12px] font-bold rounded-[7px] transition-all ${loginType === 'center' ? 'bg-white text-[#191F28] shadow-sm' : 'text-gray-400 hover:text-gray-600'}`}>{t.tabCenter}</button>
              <button onClick={() => setLoginType('admin')} className={`flex-1 py-2 text-[12px] font-bold rounded-[7px] transition-all ${loginType === 'admin' ? 'bg-white text-[#191F28] shadow-sm' : 'text-gray-400 hover:text-gray-600'}`}>{t.tabAdmin}</button>
            </div>

            {/* 입력창 (Padding 축소: py-4 -> py-3) */}
            <div className="space-y-2.5 w-full animate-slide-up">
              <input 
                type="text" 
                placeholder={t.idPlaceholder}
                value={loginId}
                onChange={(e) => setLoginId(e.target.value)}
                className="w-full px-4 py-3 bg-[#F9FAFB] rounded-xl text-[#191F28] text-[14px] font-bold outline-none focus:bg-white focus:ring-1 focus:ring-[#3182F6] border border-transparent transition-all placeholder-gray-400"
              />
              <input 
                type="password" 
                placeholder={t.pwPlaceholder}
                value={loginPw}
                onChange={(e) => setLoginPw(e.target.value)}
                className="w-full px-4 py-3 bg-[#F9FAFB] rounded-xl text-[#191F28] text-[14px] font-bold outline-none focus:bg-white focus:ring-1 focus:ring-[#3182F6] border border-transparent transition-all placeholder-gray-400"
              />
              
              {loginType === 'admin' && (
                <div className="animate-slide-up pt-1">
                   <p className="text-[11px] font-bold text-[#3182F6] mb-1 ml-1 flex items-center gap-1">🔒 {t.adminCode}</p>
                   <input 
                    type="password" 
                    placeholder={t.adminCodePlace}
                    value={adminCode}
                    onChange={(e) => setAdminCode(e.target.value)}
                    className="w-full px-4 py-3 bg-blue-50 rounded-xl text-[#191F28] text-[14px] font-bold outline-none focus:bg-white focus:ring-1 focus:ring-[#3182F6] border border-blue-100 transition-all placeholder-blue-300"
                  />
                </div>
              )}
            </div>

            {/* 아이디 저장 */}
            <div className="flex items-center justify-between px-1">
              <label className="flex items-center gap-2 cursor-pointer">
                 <div onClick={() => setSaveId(!saveId)} className={`w-4 h-4 rounded-[4px] border flex items-center justify-center transition-colors ${saveId ? 'bg-[#3182F6] border-[#3182F6]' : 'border-gray-300 bg-white'}`}>
                    {saveId && <svg className="w-2.5 h-2.5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="3" d="M5 13l4 4L19 7"/></svg>}
                 </div>
                 <span className={`text-[12px] font-bold ${saveId ? 'text-[#3182F6]' : 'text-gray-400'}`}>{t.saveId}</span>
              </label>
              <button className="text-[12px] font-bold text-gray-400 hover:text-gray-600 transition-colors">{t.findInfo}</button>
            </div>

            {/* 로그인 버튼 (크기 최적화: py-5 -> py-3.5) */}
            <button 
              onClick={handleLogin} 
              className={`w-full py-3.5 text-white rounded-xl font-bold text-[14px] transition-all shadow-md active:scale-[0.98] mt-2 
                ${loginType === 'center' ? 'bg-[#3182F6] hover:bg-[#1B64DA]' : 'bg-[#191F28] hover:bg-black'}`}
            >
               {t.loginBtn}
            </button>
            
            {/* 기관 선택 (심플한 버튼형 - 아이콘 제거) */}
            {loginType === 'center' && (
              <div className="pt-4 border-t border-gray-100 animate-slide-up">
                 <p className="text-[11px] font-bold text-gray-400 mb-2 ml-1">{t.typeLabel}</p>
                 <div className="flex gap-2">
                    <button 
                      onClick={() => setUserType('multicultural')} 
                      className={`flex-1 py-2.5 rounded-xl border text-[12px] font-bold transition-all ${userType === 'multicultural' ? 'border-[#3182F6] bg-blue-50 text-[#3182F6]' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}
                    >
                      {t.center}
                    </button>
                    <button 
                      onClick={() => setUserType('government')} 
                      className={`flex-1 py-2.5 rounded-xl border text-[12px] font-bold transition-all ${userType === 'government' ? 'border-[#3182F6] bg-blue-50 text-[#3182F6]' : 'border-gray-200 text-gray-500 hover:bg-gray-50'}`}
                    >
                      {t.gov}
                    </button>
                 </div>
              </div>
            )}
          </div>
          
          <div className="mt-auto pt-6 text-center">
            <p className="text-[10px] text-gray-300 font-medium">© V.O.M Service Inc.</p>
          </div>
        </div>
      </div>
    </div>
  );
}