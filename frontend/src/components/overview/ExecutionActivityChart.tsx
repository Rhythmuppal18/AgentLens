import React, { useEffect, useState, useMemo } from 'react';
import { Activity, Database } from 'lucide-react';
import { useApp } from '../../context/useApp';
import { fetchAnalyticsActivity } from '../../services/api';
import type { ActivityDataPoint } from '../../types';

export const ExecutionActivityChart: React.FC = () => {
  const { currentProject, environment, dateRange } = useApp();
  const [activity, setActivity] = useState<ActivityDataPoint[]>([]);

  useEffect(() => {
    let isMounted = true;

    async function loadActivity() {
      try {
        const data = await fetchAnalyticsActivity({
          project_id: currentProject?.id,
          environment,
          time_range: dateRange,
        });
        if (isMounted) {
          setActivity(data);
        }
      } catch {
        // Fall back gracefully
      }
    }

    loadActivity();
    const interval = setInterval(loadActivity, 10000);
    return () => {
      isMounted = false;
      clearInterval(interval);
    };
  }, [currentProject?.id, environment, dateRange]);

  const { points, errorPoints, hasData } = useMemo(() => {
    if (!activity || activity.length === 0) {
      return { points: '', errorPoints: '', hasData: false };
    }
    const max = Math.max(...activity.map((a) => a.total), 1);
    const anyData = activity.some((a) => a.total > 0);

    const stepX = 600 / Math.max(activity.length - 1, 1);
    const pts = activity.map((a, i) => {
      const x = Math.round(i * stepX);
      const y = Math.round(95 - (a.total / max) * 80);
      return `${x},${y}`;
    }).join(' ');

    const errPts = activity.map((a, i) => {
      const x = Math.round(i * stepX);
      const y = Math.round(95 - (a.failed / max) * 80);
      return `${x},${y}`;
    }).join(' ');

    return { points: pts, errorPoints: errPts, hasData: anyData };
  }, [activity]);

  const timeLabels = useMemo(() => {
    if (!activity || activity.length === 0) {
      return ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'];
    }
    return activity.map((a) => a.time);
  }, [activity]);

  return (
    <div className="p-3.5 sm:p-4 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-2.5 [content-visibility:auto] [contain-intrinsic-size:0_260px]">
      <div className="flex items-center justify-between pb-2 border-b border-[#252d28]">
        <div className="flex items-center gap-2">
          <Activity className="h-3.5 w-3.5 text-[#b8f56a]" />
          <h2 className="text-xs font-semibold text-[#f5f7f5] font-mono uppercase tracking-wider">
            Execution Activity Timeline
          </h2>
          <span className="text-[10px] font-mono text-[#88948a]">({dateRange})</span>
        </div>

        <div className="flex items-center gap-3 text-[10px] font-mono text-[#88948a]">
          <div className="flex items-center gap-1.5">
            <span className="h-1.5 w-1.5 rounded-full bg-[#b8f56a]" />
            <span className="text-[#9ba69e]">Executions</span>
          </div>
          <div className="flex items-center gap-1.5">
            <span className="h-1.5 w-1.5 rounded-full bg-[#f06f68]" />
            <span className="text-[#9ba69e]">Errors</span>
          </div>
        </div>
      </div>

      {/* Lightweight Native SVG Area Chart */}
      <div className="relative h-36 sm:h-40 w-full pt-1 flex flex-col justify-between">
        <div className="relative flex-1 w-full">
          <svg className="w-full h-full" viewBox="0 0 600 100" preserveAspectRatio="none" fill="none">
            {/* Grid horizontal lines */}
            <line x1="0" y1="15" x2="600" y2="15" stroke="#1c221e" strokeDasharray="3 3" />
            <line x1="0" y1="50" x2="600" y2="50" stroke="#1c221e" strokeDasharray="3 3" />
            <line x1="0" y1="85" x2="600" y2="85" stroke="#1c221e" strokeDasharray="3 3" />

            {hasData ? (
              <>
                {/* Total executions fill polygon */}
                <polygon
                  points={`0,95 ${points} 600,95`}
                  fill="url(#gradTotal)"
                  opacity="0.25"
                />
                <polyline
                  points={points}
                  stroke="#b8f56a"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />

                {/* Failed executions polyline */}
                <polyline
                  points={errorPoints}
                  stroke="#f06f68"
                  strokeWidth="1.5"
                  strokeDasharray="2 2"
                  strokeLinecap="round"
                />

                <defs>
                  <linearGradient id="gradTotal" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#b8f56a" stopOpacity="0.8" />
                    <stop offset="100%" stopColor="#b8f56a" stopOpacity="0.0" />
                  </linearGradient>
                </defs>
              </>
            ) : (
              /* Zero-state baseline path */
              <path d="M 0 95 L 600 95" stroke="#b8f56a" strokeWidth="1.5" />
            )}
          </svg>

          {/* Standby Status Pill when no live data */}
          {!hasData && (
            <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
              <div className="px-2.5 py-1 bg-[#111412] border border-[#252d28] text-xs font-mono text-[#88948a] flex items-center gap-2 rounded-xs">
                <Database className="h-3 w-3 text-[#b8f56a]" />
                <span>Standby • Telemetry stream ready</span>
              </div>
            </div>
          )}
        </div>

        {/* X-Axis Time Labels */}
        <div className="flex items-center justify-between text-[10px] font-mono text-[#88948a] pt-1">
          {timeLabels.map((t, idx) => (
            <span key={`${t}-${idx}`}>{t}</span>
          ))}
        </div>
      </div>
    </div>
  );
};
