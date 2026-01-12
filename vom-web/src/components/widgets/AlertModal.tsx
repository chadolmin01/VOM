'use client';

interface AlertModalProps {
  isOpen: boolean;
  type: 'success' | 'warning' | 'error' | 'info';
  title: string;
  description?: string;
  onClose: () => void;
  onConfirm?: () => void;
  confirmText?: string;
  cancelText?: string;
}

const TYPE_STYLES = {
  success: {
    icon: (
      <svg className="w-12 h-12 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    buttonBg: 'bg-[#3182F6] hover:bg-[#1B64DA]',
  },
  warning: {
    icon: (
      <svg className="w-12 h-12 text-yellow-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
    ),
    buttonBg: 'bg-yellow-500 hover:bg-yellow-600',
  },
  error: {
    icon: (
      <svg className="w-12 h-12 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    buttonBg: 'bg-red-500 hover:bg-red-600',
  },
  info: {
    icon: (
      <svg className="w-12 h-12 text-[#3182F6]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    buttonBg: 'bg-[#3182F6] hover:bg-[#1B64DA]',
  },
};

export default function AlertModal({
  isOpen,
  type,
  title,
  description,
  onClose,
  onConfirm,
  confirmText = '확인',
  cancelText,
}: AlertModalProps) {
  if (!isOpen) return null;

  const styles = TYPE_STYLES[type];

  const handleConfirm = () => {
    onConfirm?.();
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* 배경 오버레이 */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* 모달 본체 */}
      <div className="relative bg-white rounded-[20px] shadow-2xl w-full max-w-sm mx-4 p-8 animate-slide-up">
        {/* 아이콘 */}
        <div className="flex justify-center mb-5">
          {styles.icon}
        </div>

        {/* 제목 */}
        <h3 className="text-xl font-bold text-[#191F28] text-center mb-2">
          {title}
        </h3>

        {/* 설명 */}
        {description && (
          <p className="text-sm text-[#6B7684] text-center whitespace-pre-line leading-relaxed">
            {description}
          </p>
        )}

        {/* 버튼 영역 */}
        <div className={`mt-8 flex gap-3 ${cancelText ? 'justify-between' : 'justify-center'}`}>
          {cancelText && (
            <button
              onClick={onClose}
              className="flex-1 py-3 px-6 border border-gray-200 rounded-xl text-sm font-bold text-gray-500 hover:bg-gray-50 transition-colors"
            >
              {cancelText}
            </button>
          )}
          <button
            onClick={handleConfirm}
            className={`flex-1 py-3 px-6 text-white rounded-xl text-sm font-bold transition-colors shadow-md ${styles.buttonBg}`}
          >
            {confirmText}
          </button>
        </div>
      </div>

      <style jsx>{`
        @keyframes slide-up {
          from { opacity: 0; transform: translateY(20px) scale(0.95); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .animate-slide-up {
          animation: slide-up 0.25s ease-out forwards;
        }
      `}</style>
    </div>
  );
}
