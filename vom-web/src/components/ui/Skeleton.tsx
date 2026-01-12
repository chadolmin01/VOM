'use client';

interface SkeletonProps {
  className?: string;
}

export function Skeleton({ className = '' }: SkeletonProps) {
  return (
    <div
      className={`animate-pulse bg-gray-200 rounded ${className}`}
      aria-hidden="true"
    />
  );
}

export function CardSkeleton() {
  return (
    <div className="bg-white rounded-[14px] md:rounded-[16px] border border-gray-200 p-4 md:p-6 shadow-sm">
      <div className="flex items-center gap-3 mb-3">
        <Skeleton className="w-8 h-8 md:w-10 md:h-10 rounded-lg" />
        <Skeleton className="h-4 w-20" />
      </div>
      <Skeleton className="h-8 w-16" />
    </div>
  );
}

export function TableRowSkeleton({ columns = 6 }: { columns?: number }) {
  return (
    <tr className="animate-pulse">
      {Array.from({ length: columns }).map((_, i) => (
        <td key={i} className="px-6 py-4">
          <Skeleton className="h-4 w-full max-w-[120px]" />
        </td>
      ))}
    </tr>
  );
}

export function ListCardSkeleton() {
  return (
    <div className="bg-white rounded-[16px] border border-gray-200 shadow-sm p-4 animate-pulse">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <Skeleton className="w-11 h-11 rounded-full" />
          <div>
            <Skeleton className="h-4 w-24 mb-1" />
            <Skeleton className="h-3 w-16" />
          </div>
        </div>
        <Skeleton className="h-6 w-16 rounded-md" />
      </div>
      <div className="grid grid-cols-2 gap-3 mb-3">
        <div>
          <Skeleton className="h-3 w-12 mb-1" />
          <Skeleton className="h-4 w-20" />
        </div>
        <div>
          <Skeleton className="h-3 w-12 mb-1" />
          <Skeleton className="h-4 w-20" />
        </div>
      </div>
      <Skeleton className="h-2 w-full rounded-full mb-4" />
      <div className="flex gap-2">
        <Skeleton className="flex-1 h-11 rounded-lg" />
        <Skeleton className="flex-1 h-11 rounded-lg" />
      </div>
    </div>
  );
}
