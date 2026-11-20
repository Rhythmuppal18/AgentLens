import React, { useEffect } from 'react';
import type { ReactNode } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';

interface ModalDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  subtitle?: string;
  badge?: string;
  children: ReactNode;
  width?: string;
}

export const ModalDrawer: React.FC<ModalDrawerProps> = ({
  isOpen,
  onClose,
  title,
  subtitle,
  badge,
  children,
  width = 'max-w-2xl',
}) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 overflow-hidden flex justify-end">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-xs"
            aria-hidden="true"
          />

          {/* Drawer Panel */}
          <motion.div
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 28, stiffness: 280 }}
            className={`relative w-full ${width} bg-[#090b0a] border-l border-[#252d28] shadow-2xl flex flex-col z-10 h-full`}
          >
            {/* Drawer Header */}
            <div className="h-16 px-6 border-b border-[#252d28] flex items-center justify-between shrink-0 bg-[#111512]">
              <div className="space-y-0.5">
                <div className="flex items-center gap-2.5">
                  <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono tracking-tight">
                    {title}
                  </h2>
                  {badge && (
                    <span className="px-2 py-0.5 text-[10px] font-mono rounded bg-[#b8f56a]/15 text-[#b8f56a] border border-[#b8f56a]/30">
                      {badge}
                    </span>
                  )}
                </div>
                {subtitle && (
                  <p className="text-xs text-[#929b94] font-mono">{subtitle}</p>
                )}
              </div>

              <button
                onClick={onClose}
                className="p-1.5 text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19] rounded-lg transition-colors"
                aria-label="Close drawer"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Drawer Content */}
            <div className="flex-1 overflow-y-auto p-6 space-y-6">
              {children}
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
