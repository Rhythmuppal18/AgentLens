import React from 'react';

interface StatusBadgeProps {
  status: 'online' | 'offline' | 'warning' | 'info' | 'neutral';
  text: string;
  subtext?: string;
  pulse?: boolean;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({
  status,
  text,
  subtext,
  pulse = false,
}) => {
  const colorStyles = {
    online: 'bg-[#67c98a]/15 text-[#67c98a] border-[#67c98a]/30',
    offline: 'bg-[#f06f68]/15 text-[#f06f68] border-[#f06f68]/30',
    warning: 'bg-[#e5ad55]/15 text-[#e5ad55] border-[#e5ad55]/30',
    info: 'bg-[#b8f56a]/15 text-[#b8f56a] border-[#b8f56a]/30',
    neutral: 'bg-[#171c19] text-[#929b94] border-[#252d28]',
  };

  const dotStyles = {
    online: 'bg-[#67c98a]',
    offline: 'bg-[#f06f68]',
    warning: 'bg-[#e5ad55]',
    info: 'bg-[#b8f56a]',
    neutral: 'bg-[#626b64]',
  };

  return (
    <div
      className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-mono font-medium border transition-colors ${colorStyles[status]}`}
    >
      <span className="relative flex h-2 w-2">
        {pulse && (
          <span
            className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${dotStyles[status]}`}
          />
        )}
        <span
          className={`relative inline-flex rounded-full h-2 w-2 ${dotStyles[status]}`}
        />
      </span>
      <span>{text}</span>
      {subtext && (
        <span className="text-[10px] text-[#626b64] font-mono">({subtext})</span>
      )}
    </div>
  );
};
