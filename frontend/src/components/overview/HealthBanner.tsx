import React from 'react';
import { Server, XCircle, Terminal, RefreshCw } from 'lucide-react';
import { useApp } from '../../context/useApp';

export const HealthBanner: React.FC = () => {
  const { connectionState, refreshHealth } = useApp();
  const { isConnected, isLoading, lastChecked, latencyMs, data, errorMessage } = connectionState;

  return (
    <div
      className={`p-4 rounded-lg border transition-all ${
        isConnected
          ? 'bg-gradient-to-r from-[#b8f56a]/8 via-[#111512] to-transparent border-[#b8f56a]/30'
          : 'bg-gradient-to-r from-[#f06f68]/10 via-[#111512] to-transparent border-[#f06f68]/30'
      }`}
    >
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
        <div className="flex items-start sm:items-center gap-3">
          <div
            className={`h-9 w-9 rounded-md flex items-center justify-center shrink-0 border ${
              isConnected
                ? 'bg-[#171c19] border-[#b8f56a]/30 text-[#b8f56a]'
                : 'bg-[#171c19] border-[#f06f68]/30 text-[#f06f68]'
            }`}
          >
            {isConnected ? <Server className="h-4 w-4" /> : <XCircle className="h-4 w-4" />}
          </div>

          <div className="space-y-0.5">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-xs font-semibold text-[#f5f7f5] font-mono">
                {data?.service || 'AgentLens Backend API'}
              </span>
              <span
                className={`px-1.5 py-0.2 text-[8px] font-mono font-semibold uppercase tracking-widest rounded border ${
                  isConnected
                    ? 'bg-[#67c98a]/10 text-[#83cda0] border-[#67c98a]/30'
                    : 'bg-[#f06f68]/10 text-[#f6928d] border-[#f06f68]/30'
                }`}
              >
                {isConnected ? 'ONLINE • HEALTHY' : 'UNREACHABLE'}
              </span>
              {data?.version && (
                <span className="text-[9px] font-mono text-[#929b94] bg-[#171c19] px-1.5 py-0.2 rounded border border-[#252d28]">
                  v{data.version}
                </span>
              )}
            </div>

            <p className="text-[11px] text-[#929b94] font-mono">
              Target: <span className="text-[#f5f7f5]">GET http://localhost:8000/health</span>
              {latencyMs !== null && (
                <span className="ml-2 text-[#b8f56a]">&bull; {latencyMs}ms roundtrip</span>
              )}
              {lastChecked && (
                <span className="ml-2 text-[#626b64]">&bull; checked {lastChecked.toLocaleTimeString()}</span>
              )}
            </p>
          </div>
        </div>

        {/* Action Button & Diagnostics if offline */}
        <div className="flex items-center gap-2">
          {!isConnected ? (
            <div className="text-[10px] font-mono text-[#f6928d] flex items-center gap-2 bg-[#090b0a] px-2 py-1 rounded border border-[#f06f68]/30">
              <Terminal className="h-3 w-3 text-[#f06f68]" />
              <span>{errorMessage || 'python -m uvicorn app.main:app --reload --app-dir backend'}</span>
            </div>
          ) : null}

          <button
            onClick={refreshHealth}
            disabled={isLoading}
            className="p-1.5 rounded-md bg-[#171c19] hover:bg-[#202621] border border-[#252d28] text-xs font-mono text-[#929b94] hover:text-[#f5f7f5] transition-colors"
            title="Recheck health"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin text-[#b8f56a]' : ''}`} />
          </button>
        </div>
      </div>
    </div>
  );
};
