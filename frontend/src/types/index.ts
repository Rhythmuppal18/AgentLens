export type NavigationTab =
  | 'overview'
  | 'traces'
  | 'failures'
  | 'analytics'
  | 'settings';

export type Environment = 'production' | 'staging' | 'development';
export type DateRange = '1h' | '24h' | '7d' | '30d' | 'custom';

export interface Project {
  id: string;
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
  | 'ROUTING';

export type SpanStatus = 'OK' | 'ERROR' | 'RUNNING';

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
  agentName: string;
  sessionId: string;
  status: 'SUCCESS' | 'FAILED' | 'RUNNING';
  startTime: string;
  endTime: string | null;
  durationMs: number;
  totalTokens: number;
  costUsd: number;
  rootSpanName: string;
  spanCount: number;
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
}
