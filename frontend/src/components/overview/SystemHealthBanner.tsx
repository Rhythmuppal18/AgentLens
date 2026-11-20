import React from 'react';
import {
  Server,
  XCircle,
  RefreshCw,
  Terminal,
  Clock
} from 'lucide-react';
import type { BackendConnectionState } from '../../types';

interface SystemHealthBannerProps {
  connectionState: BackendConnectionState;
  onRefresh: () => void;
}

export const SystemHealthBanner: React.FC<SystemHealthBannerProps> = ({
  connectionState,
  onRefresh,
}) => {
  const { isConnected, isLoading, lastChecked, latencyMs, data, errorMessage } = connectionState;

  return (
    <div
      className={`p-5 rounded-xl border transition-all ${
        isConnected
          ? 'bg-gradient-to-r from-[#0F172A] via-[#0F172A] to-emerald-950/20 border-emerald-500/30'
          : 'bg-gradient-to-r from-[#0F172A] via-[#0F172A] to-rose-950/20 border-rose-500/30'
      }`}
    >
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        {/* Left: Status & Service Details */}
        <div className="flex items-start gap-3.5">
          <div
            className={`h-11 w-11 rounded-lg flex items-center justify-center shrink-0 border ${
              isConnected
                ? 'bg-emerald-500/10 border-emerald-500/30 text-emerald-400'
                : 'bg-rose-500/10 border-rose-500/30 text-rose-400'
            }`}
          >
            {isConnected ? (
              <Server className="h-5 w-5" />
            ) : (
              <XCircle className="h-5 w-5" />
            )}
          </div>

          <div className="space-y-1">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-sm font-semibold text-slate-100 font-mono">
                {data?.service || 'AgentLens Backend API'}
              </span>
              <span
                className={`px-2 py-0.5 text-[10px] font-mono font-semibold rounded-full border ${
                  isConnected
                    ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/30'
                    : 'bg-rose-500/15 text-rose-400 border-rose-500/30'
                }`}
              >
                {isConnected ? 'ONLINE / HEALTHY' : 'UNREACHABLE'}
              </span>
              {data?.version && (
                <span className="text-[10px] font-mono text-slate-400 bg-slate-800/80 px-2 py-0.5 rounded border border-slate-700/60">
                  v{data.version}
                </span>
              )}
            </div>

            <p className="text-xs text-slate-400 font-mono">
              Target:{' '}
              <span className="text-slate-300">
                GET http://localhost:8000/health
              </span>
              {latencyMs !== null && (
                <span className="ml-2 text-emerald-400">
                  &bull; Latency: {latencyMs}ms
                </span>
              )}
            </p>

            {/* Error or Help guidance if disconnected */}
            {!isConnected && (
              <div className="pt-2 text-xs font-mono text-rose-300 space-y-1">
                <p className="text-rose-400 font-semibold">
                  Diagnostic Alert: {errorMessage || 'Could not reach FastAPI server.'}
                </p>
                <p className="text-slate-400 text-[11px]">
                  Ensure the Uvicorn server is running locally:
                </p>
                <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded bg-[#0B0F17] border border-rose-500/20 text-slate-300 text-[11px]">
                  <Terminal className="h-3 w-3 text-rose-400" />
                  <code>python -m uvicorn app.main:app --reload --app-dir backend</code>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Right: Health Actions & Timestamp */}
        <div className="flex md:flex-col items-center md:items-end justify-between md:justify-center gap-2 pt-2 md:pt-0 border-t md:border-t-0 border-slate-800/80">
          <button
            onClick={onRefresh}
            disabled={isLoading}
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-[#0B0F17] hover:bg-slate-800/80 border border-slate-700/80 hover:border-slate-600 text-xs font-mono text-slate-200 transition-all shadow-xs"
          >
            <RefreshCw
              className={`h-3.5 w-3.5 text-violet-400 ${
                isLoading ? 'animate-spin' : ''
              }`}
            />
            <span>{isLoading ? 'Checking...' : 'Re-verify Health'}</span>
          </button>

          {lastChecked && (
            <div className="flex items-center gap-1 text-[10px] font-mono text-slate-500">
              <Clock className="h-3 w-3" />
              <span>Checked {lastChecked.toLocaleTimeString()}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
