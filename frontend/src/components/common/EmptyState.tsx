import React from 'react';
import type { ReactNode } from 'react';
import type { LucideIcon } from 'lucide-react';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  badgeText?: string;
  badgeVariant?: 'neutral' | 'warning' | 'info';
  action?: {
    label: string;
    onClick: () => void;
  };
  children?: ReactNode;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  icon: Icon,
  title,
  description,
  badgeText,
  badgeVariant = 'neutral',
  action,
  children,
}) => {
  const badgeStyles = {
    neutral: 'bg-[#171c19] text-[#929b94] border-[#252d28]',
    warning: 'bg-[#e5ad55]/15 text-[#e5ad55] border-[#e5ad55]/30',
    info: 'bg-[#b8f56a]/15 text-[#b8f56a] border-[#b8f56a]/30',
  };

  return (
    <div className="py-12 px-6 rounded-xl bg-[#111512]/70 border border-dashed border-[#252d28] flex flex-col items-center justify-center text-center space-y-4">
      <div className="h-12 w-12 rounded-xl bg-[#171c19] border border-[#252d28] flex items-center justify-center text-[#929b94] shadow-inner">
        <Icon className="h-6 w-6 text-[#929b94]" />
      </div>

      <div className="max-w-md space-y-1.5">
        <div className="flex items-center justify-center gap-2">
          <h3 className="text-sm font-semibold text-[#f5f7f5] font-mono tracking-tight">
            {title}
          </h3>
          {badgeText && (
            <span
              className={`text-[10px] font-mono px-2 py-0.5 rounded-full border ${badgeStyles[badgeVariant]}`}
            >
              {badgeText}
            </span>
          )}
        </div>
        <p className="text-xs text-[#929b94] leading-relaxed font-sans">
          {description}
        </p>
      </div>

      {action && (
        <button
          onClick={action.onClick}
          className="px-3.5 py-1.5 rounded-lg bg-[#b8f56a]/15 hover:bg-[#b8f56a]/25 border border-[#b8f56a]/30 text-xs font-mono text-[#b8f56a] transition-colors font-medium shadow-xs"
        >
          {action.label}
        </button>
      )}

      {children && <div className="w-full pt-2">{children}</div>}
    </div>
  );
};
