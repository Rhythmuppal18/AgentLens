import React from 'react';
import {
  LayoutDashboard,
  GitFork,
  ShieldAlert,
  BarChart3,
  Settings,
  ExternalLink,
  BookOpen,
  Wifi,
  WifiOff,
  X
} from 'lucide-react';
import type { NavigationTab } from '../../types';
import { useApp } from '../../context/useApp';

interface NavItemConfig {
  id: NavigationTab;
  label: string;
  icon: React.ElementType;
  badge?: string;
}

const NAV_ITEMS: NavItemConfig[] = [
  {
    id: 'overview',
    label: 'Overview',
    icon: LayoutDashboard,
  },
  {
    id: 'traces',
    label: 'Traces',
    icon: GitFork,
    badge: 'Core',
  },
  {
    id: 'failures',
    label: 'Failures',
    icon: ShieldAlert,
    badge: 'Rules',
  },
  {
    id: 'analytics',
    label: 'Analytics',
    icon: BarChart3,
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: Settings,
  },
];

export const Sidebar: React.FC = () => {
  const {
    activeTab,
    setActiveTab,
    connectionState,
    isMobileNavOpen,
    setIsMobileNavOpen
  } = useApp();

  return (
    <>
      {/* Mobile backdrop */}
      {isMobileNavOpen && (
        <div
          onClick={() => setIsMobileNavOpen(false)}
          className="fixed inset-0 bg-black/70 backdrop-blur-xs z-40 lg:hidden transition-opacity"
          aria-hidden="true"
        />
      )}

      <aside
        className={`fixed top-0 bottom-0 left-0 z-50 w-64 bg-[#090b0a] border-r border-[#252d28] flex flex-col transition-transform duration-200 ease-in-out lg:translate-x-0 ${
          isMobileNavOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        {/* Brand Header */}
        <div className="h-14 px-5 border-b border-[#252d28] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <svg className="h-5 w-5 text-[#b8f56a] shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M12 2L2 12l10 10 10-10L12 2z" />
              <path d="M12 7L7 12l5 5 5-5L12 7z" strokeWidth="1.2" opacity="0.6" />
            </svg>
            <div className="flex items-baseline gap-1.5">
              <span className="font-semibold text-[#f5f7f5] tracking-tight text-sm font-sans">
                AgentLens
              </span>
              <span className="text-[8px] font-mono text-[#88948a] uppercase tracking-wider">
                Platform
              </span>
            </div>
          </div>

          <button
            onClick={() => setIsMobileNavOpen(false)}
            className="lg:hidden p-1.5 text-[#9ba69e] hover:text-[#f5f7f5] hover:bg-[#171c19] rounded-md"
            aria-label="Close sidebar"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Tagline */}
        <div className="px-5 py-2.5 bg-[#0d100e] border-b border-[#252d28]">
          <p className="text-[10px] font-mono text-[#88948a] leading-relaxed">
            See the trace. Find the failure. Debug with evidence.
          </p>
        </div>

        {/* Navigation Items */}
        <nav className="flex-1 px-3 py-3 space-y-0.5 overflow-y-auto">
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;

            return (
              <button
                key={item.id}
                onClick={() => {
                  setActiveTab(item.id);
                  setIsMobileNavOpen(false);
                }}
                className={`w-full flex items-center justify-between px-3 py-2 text-xs font-mono transition-colors text-left ${
                  isActive
                    ? 'bg-[#141815] text-[#f5f7f5] border-l-2 border-[#b8f56a] font-medium'
                    : 'text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#101311] border-l-2 border-transparent'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <Icon
                    className={`h-4 w-4 transition-colors ${
                      isActive
                        ? 'text-[#b8f56a]'
                        : 'text-[#88948a]'
                    }`}
                  />
                  <span>{item.label}</span>
                </div>

                {item.badge && (
                  <span
                    className={`text-[8px] font-mono uppercase tracking-wider px-1.5 py-0.2 rounded-xs border ${
                      isActive
                        ? 'bg-[#b8f56a]/15 text-[#b8f56a] border-[#b8f56a]/30'
                        : 'bg-[#171c19] text-[#9ba69e] border-[#252d28]'
                    }`}
                  >
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Daemon Connection Mini-Card */}
        <div className="p-3 border-t border-[#252d28] bg-[#080908]">
          <div className="p-2.5 bg-[#0d100e] border border-[#252d28] space-y-1">
            <div className="flex items-center justify-between">
              <span className="text-[10px] font-mono text-[#9ba69e]">Daemon :8000</span>
              {connectionState.isConnected ? (
                <span className="inline-flex items-center gap-1 text-[10px] text-[#67c98a] font-mono font-medium">
                  <Wifi className="h-3 w-3" />
                  {connectionState.latencyMs !== null ? `${connectionState.latencyMs}ms` : 'Ready'}
                </span>
              ) : (
                <span className="inline-flex items-center gap-1 text-[10px] text-[#f06f68] font-mono font-medium">
                  <WifiOff className="h-3 w-3" />
                  Offline
                </span>
              )}
            </div>
            <div className="text-[10px] text-[#929b94] font-mono truncate">
              {connectionState.isConnected
                ? (connectionState.data?.service || 'AgentLens Backend')
                : 'Uvicorn not responding'}
            </div>
          </div>
        </div>

        {/* Docs & Repo Link */}
        <div className="px-4 py-3 border-t border-[#252d28] flex items-center justify-between text-xs text-[#929b94] font-mono">
          <a
            href="https://github.com/Rhythmuppal18/AgentLens"
            target="_blank"
            rel="noreferrer"
            className="flex items-center gap-1 hover:text-[#f5f7f5] transition-colors"
          >
            <BookOpen className="h-3.5 w-3.5" />
            <span className="text-[11px]">Docs & Repo</span>
            <ExternalLink className="h-3 w-3 opacity-60 ml-0.5" />
          </a>
          <span className="text-[10px] text-[#9ba69e]">Localhost</span>
        </div>
      </aside>
    </>
  );
};
