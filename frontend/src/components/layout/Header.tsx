import React, { useState } from 'react';
import {
  Search,
  RefreshCw,
  Menu,
  ChevronDown,
  FolderGit2,
  Calendar,
  Info
} from 'lucide-react';
import { useApp } from '../../context/useApp';
import type { Environment, DateRange } from '../../types';

export const Header: React.FC = () => {
  const {
    currentProject,
    setCurrentProject,
    projects,
    environment,
    setEnvironment,
    dateRange,
    setDateRange,
    connectionState,
    refreshHealth,
    setIsMobileNavOpen,
    activeTab,
  } = useApp();

  const [searchFocused, setSearchFocused] = useState(false);
  const [searchValue, setSearchValue] = useState('');
  const [isProjectDropdownOpen, setIsProjectDropdownOpen] = useState(false);
  const [isEnvDropdownOpen, setIsEnvDropdownOpen] = useState(false);
  const [isDateDropdownOpen, setIsDateDropdownOpen] = useState(false);

  const ENV_OPTIONS: Environment[] = ['development', 'staging', 'production'];
  const DATE_OPTIONS: { label: string; value: DateRange }[] = [
    { label: 'Last 1 Hour', value: '1h' },
    { label: 'Last 24 Hours', value: '24h' },
    { label: 'Last 7 Days', value: '7d' },
    { label: 'Last 30 Days', value: '30d' },
  ];

  return (
    <header className="h-14 bg-[#080908] border-b border-[#252d28] sticky top-0 z-30 px-4 lg:px-6 flex items-center justify-between gap-3">
      {/* Left: Mobile Toggle & Project / Environment Selectors */}
      <div className="flex items-center gap-2.5">
        <button
          onClick={() => setIsMobileNavOpen(true)}
          className="lg:hidden p-1.5 text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19] rounded-md"
          aria-label="Open navigation menu"
        >
          <Menu className="h-5 w-5" />
        </button>

        {/* Project Selector Dropdown */}
        <div className="relative">
          <button
            onClick={() => {
              setIsProjectDropdownOpen(!isProjectDropdownOpen);
              setIsEnvDropdownOpen(false);
              setIsDateDropdownOpen(false);
            }}
            className="flex items-center gap-2 px-2.5 py-1.5 rounded-md bg-[#111512] border border-[#252d28] hover:border-[#303a33] text-xs font-mono text-[#f5f7f5] transition-colors"
          >
            <FolderGit2 className="h-3.5 w-3.5 text-[#b8f56a]" />
            <span className="font-medium max-w-[140px] truncate sm:max-w-none">
              {currentProject.name}
            </span>
            <ChevronDown className="h-3 w-3 text-[#929b94]" />
          </button>

          {isProjectDropdownOpen && (
            <div className="absolute top-full left-0 mt-1.5 w-56 p-1 bg-[#111512] border border-[#252d28] rounded-md shadow-2xl shadow-black/80 z-50">
              <div className="px-2 py-1 text-[9px] font-mono uppercase tracking-wider text-[#929b94] font-semibold">
                Select Agent Project
              </div>
              {projects.map((proj) => (
                <button
                  key={proj.id}
                  onClick={() => {
                    setCurrentProject(proj);
                    setIsProjectDropdownOpen(false);
                  }}
                  className={`w-full text-left px-2 py-1.5 rounded text-xs font-mono flex items-center justify-between ${
                    currentProject.id === proj.id
                      ? 'bg-[#1a201c] text-[#f5f7f5] font-medium border-l-2 border-[#b8f56a]'
                      : 'text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19]'
                  }`}
                >
                  <span className="truncate">{proj.name}</span>
                  {currentProject.id === proj.id && (
                    <span className="h-1.5 w-1.5 rounded-full bg-[#b8f56a]" />
                  )}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Environment Selector */}
        <div className="relative hidden sm:block">
          <button
            onClick={() => {
              setIsEnvDropdownOpen(!isEnvDropdownOpen);
              setIsProjectDropdownOpen(false);
              setIsDateDropdownOpen(false);
            }}
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md bg-[#111512] border border-[#252d28] hover:border-[#303a33] text-xs font-mono text-[#f5f7f5] transition-colors"
          >
            <span className={`h-1.5 w-1.5 rounded-full ${
              environment === 'production'
                ? 'bg-[#67c98a]'
                : environment === 'staging'
                ? 'bg-[#e5ad55]'
                : 'bg-[#b8f56a]'
            }`} />
            <span className="capitalize">{environment}</span>
            <ChevronDown className="h-3 w-3 text-[#929b94]" />
          </button>

          {isEnvDropdownOpen && (
            <div className="absolute top-full left-0 mt-1.5 w-36 p-1 bg-[#111512] border border-[#252d28] rounded-md shadow-2xl shadow-black/80 z-50">
              {ENV_OPTIONS.map((env) => (
                <button
                  key={env}
                  onClick={() => {
                    setEnvironment(env);
                    setIsEnvDropdownOpen(false);
                  }}
                  className={`w-full text-left px-2 py-1.5 rounded text-xs font-mono capitalize ${
                    environment === env
                      ? 'bg-[#1a201c] text-[#b8f56a] font-medium'
                      : 'text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19]'
                  }`}
                >
                  {env}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Date Range Control */}
        {(activeTab === 'overview' || activeTab === 'analytics') && (
          <div className="relative hidden md:block">
            <button
              onClick={() => {
                setIsDateDropdownOpen(!isDateDropdownOpen);
                setIsProjectDropdownOpen(false);
                setIsEnvDropdownOpen(false);
              }}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md bg-[#111512] border border-[#252d28] hover:border-[#303a33] text-xs font-mono text-[#f5f7f5] transition-colors"
            >
              <Calendar className="h-3.5 w-3.5 text-[#929b94]" />
              <span>{DATE_OPTIONS.find((d) => d.value === dateRange)?.label || 'Last 24 Hours'}</span>
              <ChevronDown className="h-3 w-3 text-[#929b94]" />
            </button>

            {isDateDropdownOpen && (
              <div className="absolute top-full left-0 mt-1.5 w-44 p-1 bg-[#111512] border border-[#252d28] rounded-md shadow-2xl shadow-black/80 z-50">
                {DATE_OPTIONS.map((option) => (
                  <button
                    key={option.value}
                    onClick={() => {
                      setDateRange(option.value);
                      setIsDateDropdownOpen(false);
                    }}
                    className={`w-full text-left px-2 py-1.5 rounded text-xs font-mono ${
                      dateRange === option.value
                        ? 'bg-[#1a201c] text-[#b8f56a] font-medium'
                        : 'text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19]'
                    }`}
                  >
                    {option.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Center: Global Search */}
      <div className="relative flex-1 max-w-sm hidden xl:block">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-[#929b94]" />
          <input
            type="text"
            value={searchValue}
            onChange={(e) => setSearchValue(e.target.value)}
            onFocus={() => setSearchFocused(true)}
            onBlur={() => setTimeout(() => setSearchFocused(false), 200)}
            placeholder="Search traces, spans, run IDs... (Cmd+K)"
            aria-label="Search traces, spans, run IDs"
            className="w-full pl-8 pr-14 py-1.5 bg-[#111512] border border-[#252d28] rounded-md text-xs text-[#f5f7f5] placeholder:text-[#88948a] focus:outline-hidden focus:border-[#b8f56a]/60 focus:ring-1 focus:ring-[#b8f56a]/30 font-mono transition-all"
          />
          <kbd className="absolute right-2 top-1/2 -translate-y-1/2 px-1.5 py-0.5 text-[9px] font-mono text-[#929b94] bg-[#171c19] rounded border border-[#252d28] pointer-events-none">
            Ctrl K
          </kbd>
        </div>

        {searchFocused && (
          <div className="absolute top-full left-0 right-0 mt-2 p-3 bg-[#111512] border border-[#252d28] rounded-md shadow-2xl shadow-black/90 z-50 text-xs">
            <div className="flex items-start gap-2 text-[#b8f56a]">
              <Info className="h-4 w-4 shrink-0 mt-0.5 text-[#b8f56a]" />
              <div>
                <p className="font-semibold text-[#f5f7f5] font-mono">Telemetry Index Standby</p>
                <p className="text-[#929b94] text-[11px] mt-0.5">
                  Trace and failure indexing will be queried dynamically once the Python SDK streams runtime telemetry.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Right: Backend Connection Status Pill */}
      <div className="flex items-center gap-2">
        {connectionState.isConnected ? (
          <div
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#67c98a]/10 border border-[#67c98a]/30 text-[#83cda0] text-[10px] font-mono font-medium"
            title={`FastAPI ${connectionState.data?.version || '0.1.0'} running on localhost:8000`}
          >
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#67c98a] opacity-75" />
              <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-[#67c98a]" />
            </span>
            <span className="hidden sm:inline font-medium">FastAPI Online</span>
            <span className="sm:hidden font-medium">Online</span>
            {connectionState.latencyMs !== null && (
              <span className="text-[9px] text-[#67c98a]/80 hidden md:inline">
                {connectionState.latencyMs}ms
              </span>
            )}
          </div>
        ) : (
          <div
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#f06f68]/10 border border-[#f06f68]/30 text-[#f6928d] text-[10px] font-mono font-medium"
            title={connectionState.errorMessage || 'Cannot reach FastAPI server'}
          >
            <span className="h-1.5 w-1.5 rounded-full bg-[#f06f68]" />
            <span className="font-medium">API Offline</span>
          </div>
        )}

        <button
          onClick={refreshHealth}
          disabled={connectionState.isLoading}
          className="p-1.5 rounded-md bg-[#111512] border border-[#252d28] text-[#929b94] hover:text-[#f5f7f5] hover:border-[#303a33] transition-colors"
          title="Recheck FastAPI health endpoint"
          aria-label="Refresh connection"
        >
          <RefreshCw
            className={`h-3.5 w-3.5 ${connectionState.isLoading ? 'animate-spin text-[#b8f56a]' : ''}`}
          />
        </button>
      </div>
    </header>
  );
};
