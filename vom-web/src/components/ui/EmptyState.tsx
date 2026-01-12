'use client';

interface EmptyStateProps {
  icon?: string;
  title: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
}

export default function EmptyState({
  icon = '📭',
  title,
  description,
  actionLabel,
  onAction,
}: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-12 px-4 text-center">
      <span className="text-5xl mb-4" role="img" aria-hidden="true">
        {icon}
      </span>
      <h3 className="text-lg font-bold text-gray-700 mb-2">{title}</h3>
      {description && (
        <p className="text-sm text-gray-500 max-w-sm mb-4">{description}</p>
      )}
      {actionLabel && onAction && (
        <button
          onClick={onAction}
          className="px-5 py-3 bg-[#3182F6] text-white rounded-xl text-sm font-bold hover:bg-[#1B64DA] transition-colors min-h-[44px]"
        >
          {actionLabel}
        </button>
      )}
    </div>
  );
}
