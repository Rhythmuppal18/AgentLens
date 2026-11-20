import React from 'react';
import { HeroTraceFlightRecorder } from './HeroTraceFlightRecorder';
import { ExecutionStats } from './ExecutionStats';
import { ExecutionActivityChart } from './ExecutionActivityChart';
import { RecentTracesTable } from './RecentTracesTable';
import { DeterministicRulesGrid } from './DeterministicRulesGrid';

export const OverviewView: React.FC = () => {
  return (
    <div className="space-y-4 sm:space-y-5">
      {/* 1. Hero Trace Flight Recorder & Strategic Value */}
      <HeroTraceFlightRecorder />

      {/* 2. Unified 4-Column Execution Metrics Strip */}
      <ExecutionStats />

      {/* 3. Two-Column Operational Layout: Timeline & Recent Executions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-5">
        <ExecutionActivityChart />
        <RecentTracesTable />
      </div>

      {/* 4. Five Deterministic Signals Grid (Figma Design) */}
      <DeterministicRulesGrid />
    </div>
  );
};
