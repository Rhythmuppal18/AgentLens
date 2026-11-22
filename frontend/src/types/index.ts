export type NavigationTab =
  | 'overview'
  | 'traces'
  | 'failures'
  | 'analytics'
  | 'ml-playground'
  | 'settings';

export type Environment = 'production' | 'staging' | 'development' | string;
export type DateRange = '1h' | '24h' | '7d' | '30d' | 'custom';

export interface Project {
  id: string;
  name: string;
  slug: string;
  createdAt: string;
  apiKey?: string;
  apiKeyPrefix?: string;
}

export interface EnvironmentInfo {
  id: string;
  projectId: string;
  name: string;
  slug: string;
  createdAt: string;
}

export interface BackendHealthResponse {
  status: 'healthy' | 'degraded' | 'unhealthy' | string;
  service: string;
  version: string;
}

export interface BackendConnectionState {
  isConnected: boolean;
  isLoading: boolean;
  lastChecked: Date | null;
  latencyMs: number | null;
  data: BackendHealthResponse | null;
  errorMessage: string | null;
}

export type SpanType =
  | 'AGENT_STEP'
  | 'LLM_CALL'
  | 'TOOL_CALL'
  | 'RETRIEVAL'
  | 'ROUTING'
  | string;

export type SpanStatus = 'OK' | 'ERROR' | 'RUNNING' | string;

export interface SpanEvent {
  timestamp: string;
  name: string;
  data: Record<string, unknown>;
}

export interface SpanAttributes {
  model?: string;
  promptTokens?: number;
  completionTokens?: number;
  totalTokens?: number;
  costUsd?: number;
  temperature?: number;
  toolName?: string;
  retryCount?: number;
  [key: string]: unknown;
}

export interface Span {
  id: string;
  traceId: string;
  parentSpanId: string | null;
  name: string;
  spanType: SpanType;
  status: SpanStatus;
  startTime: string;
  endTime: string | null;
  durationMs: number;
  inputPayload: Record<string, unknown> | string | null;
  outputPayload: Record<string, unknown> | string | null;
  errorMessage: string | null;
  events: SpanEvent[];
  attributes: SpanAttributes;
  children?: Span[];
}

export interface Trace {
  id: string;
  projectId?: string;
  environmentId?: string;
  agentName: string;
  sessionId: string | null;
  status: 'SUCCESS' | 'FAILED' | 'RUNNING' | string;
  startTime: string;
  endTime: string | null;
  durationMs: number;
  totalTokens: number;
  costUsd: number;
  rootSpanName: string;
  spanCount: number;
  hasFailures?: boolean;
  spans: Span[];
}

export type FailureRuleType =
  | 'FAILED_SPAN'
  | 'REPEATED_TOOL_CALL'
  | 'EXCESSIVE_RETRIES'
  | 'SLOW_SPAN'
  | 'EMPTY_TOOL_RESULT';

export type FailureSeverity = 'CRITICAL' | 'HIGH' | 'WARNING';

export interface FailureRuleDefinition {
  id: FailureRuleType;
  name: string;
  description: string;
  condition: string;
  status: 'standby' | 'active';
  severity: FailureSeverity;
  count?: number;
  activeThresholdMs?: number | null;
}

export interface FailureViolation {
  id: string;
  traceId: string;
  spanId: string;
  spanName: string;
  ruleType: FailureRuleType;
  severity: FailureSeverity;
  timestamp: string;
  evidenceSummary: string;
  evidenceData: Record<string, unknown>;
  fingerprint?: string;
}

export interface AnalyticsOverview {
  totalExecutions: number;
  failedExecutions: number;
  errorRate: number;
  p95LatencyMs: number | null;
  avgDurationMs: number | null;
  totalTokens: number;
  estimatedCostUsd: number;
  isTelemetryStandby: boolean;
}

export interface ActivityDataPoint {
  time: string;
  total: number;
  failed: number;
  success: number;
}

export interface RuleMetric {
  id: FailureRuleType;
  name: string;
  description: string;
  condition: string;
  severity: FailureSeverity;
  count: number;
  activeThresholdMs?: number | null;
}

export interface AgentMetric {
  agentName: string;
  executions: number;
  errorRate: number;
  avgDurationMs: number;
  totalTokens: number;
}

export interface ToolMetric {
  toolName: string;
  calls: number;
  errorRate: number;
  avgDurationMs: number;
}
