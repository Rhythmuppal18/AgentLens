import React from 'react';
import {
  Server,
  GitFork,
  ShieldAlert,
  Activity
} from 'lucide-react';
import type { BackendConnectionState } from '../../types';

interface MetricCardsProps {
  connectionState: BackendConnectionState;
}

export const MetricCards: React.FC<MetricCardsProps> = ({ connectionState }) => {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {/* 1. Backend Status Card */}
      <div className="p-4 rounded-xl bg-[#0F172A] border border-slate-800 hover:border-slate-700/80 transition-all flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-mono text-slate-400 font-medium">
            Backend Status
          </span>
          <div
            className={`p-1.5 rounded-md ${
              connectionState.isConnected
                ? 'bg-emerald-500/10 text-emerald-400'
                : 'bg-rose-500/10 text-rose-400'
            }`}
          >
            <Server className="h-4 w-4" />
          </div>
        </div>

        <div className="my-3">
          <div className="flex items-baseline gap-2">
            <span
              className={`text-2xl font-bold font-mono tracking-tight ${
                connectionState.isConnected ? 'text-emerald-400' : 'text-rose-400'
              }`}
            >
              {connectionState.isConnected ? 'HEALTHY' : 'OFFLINE'}
            </span>
          </div>
          <p className="text-[11px] font-mono text-slate-400 mt-1 truncate">
            {connectionState.isConnected
              ? `FastAPI ${connectionState.data?.version || '0.1.0'} on :8000`
              : 'Failed to connect to FastAPI'}
          </p>
        </div>

        <div className="pt-2 border-t border-slate-800/80 flex items-center justify-between text-[11px] font-mono">
          <span className="text-slate-500">Service</span>
          <span className="text-slate-300">
            {connectionState.data?.service || 'AgentLens API'}
          </span>
        </div>
      </div>

      {/* 2. Traces Captured Card */}
      <div className="p-4 rounded-xl bg-[#0F172A] border border-slate-800 hover:border-slate-700/80 transition-all flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-mono text-slate-400 font-medium">
            Traces Captured
          </span>
          <div className="p-1.5 rounded-md bg-violet-500/10 text-violet-400">
            <GitFork className="h-4 w-4" />
          </div>
        </div>

        <div className="my-3">
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono text-slate-100 tracking-tight">
              0
            </span>
            <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-slate-800 text-slate-400 border border-slate-700/60">
              Awaiting SDK
            </span>
          </div>
          <p className="text-[11px] font-mono text-slate-400 mt-1">
            Telemetry ingestion awaiting Stage 4
          </p>
        </div>

        <div className="pt-2 border-t border-slate-800/80 flex items-center justify-between text-[11px] font-mono">
          <span className="text-slate-500">Active Spans</span>
          <span className="text-slate-400">0 recorded</span>
        </div>
      </div>

      {/* 3. Detected Failures Card */}
      <div className="p-4 rounded-xl bg-[#0F172A] border border-slate-800 hover:border-slate-700/80 transition-all flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-mono text-slate-400 font-medium">
            Detected Failures
          </span>
          <div className="p-1.5 rounded-md bg-amber-500/10 text-amber-400">
            <ShieldAlert className="h-4 w-4" />
          </div>
        </div>

        <div className="my-3">
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono text-slate-100 tracking-tight">
              0
            </span>
            <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              0 Violations
            </span>
          </div>
          <p className="text-[11px] font-mono text-slate-400 mt-1">
            5 Deterministic Rules on standby
          </p>
        </div>

        <div className="pt-2 border-t border-slate-800/80 flex items-center justify-between text-[11px] font-mono">
          <span className="text-slate-500">Rule Engine</span>
          <span className="text-emerald-400">Ready</span>
        </div>
      </div>

      {/* 4. Execution Activity Card */}
      <div className="p-4 rounded-xl bg-[#0F172A] border border-slate-800 hover:border-slate-700/80 transition-all flex flex-col justify-between">
        <div className="flex items-center justify-between">
          <span className="text-xs font-mono text-slate-400 font-medium">
            Execution Activity
          </span>
          <div className="p-1.5 rounded-md bg-indigo-500/10 text-indigo-400">
            <Activity className="h-4 w-4" />
          </div>
        </div>

        <div className="my-3">
          <div className="flex items-baseline gap-2">
            <span className="text-2xl font-bold font-mono text-slate-100 tracking-tight">
              0.0s
            </span>
            <span className="px-1.5 py-0.5 text-[10px] font-mono rounded bg-slate-800 text-slate-400 border border-slate-700/60">
              0 runs
            </span>
          </div>
          <p className="text-[11px] font-mono text-slate-400 mt-1">
            No agent execution logged yet
          </p>
        </div>

        <div className="pt-2 border-t border-slate-800/80 flex items-center justify-between text-[11px] font-mono">
          <span className="text-slate-500">Avg Latency</span>
          <span className="text-slate-500">-- ms</span>
        </div>
      </div>
    </div>
  );
};
