import type {
  ActivityDataPoint,
  AgentMetric,
  AnalyticsOverview,
  BackendConnectionState,
  BackendHealthResponse,
  EnvironmentInfo,
  FailureRuleType,
  FailureSeverity,
  FailureViolation,
  Project,
  RuleMetric,
  Span,
  SpanEvent,
  ToolMetric,
  Trace,
} from '../types';

const PRIMARY_HEALTH_URL = 'http://localhost:8000/health';
const FALLBACK_HEALTH_URL = '/health';

const getApiBaseUrl = (): string => {
  if (typeof window !== 'undefined' && window.location.origin) {
    return '/api/v1';
  }
  return 'http://localhost:8000/api/v1';
};

const getDirectApiBaseUrl = (): string => 'http://localhost:8000/api/v1';

async function requestJson<T>(path: string, options: RequestInit = {}): Promise<T> {
  const relativeBase = getApiBaseUrl();
  const directBase = getDirectApiBaseUrl();

  const url = `${relativeBase}${path.startsWith('/') ? path : `/${path}`}`;
  const directUrl = `${directBase}${path.startsWith('/') ? path : `/${path}`}`;

  const headers = {
    'Accept': 'application/json',
    ...(options.body ? { 'Content-Type': 'application/json' } : {}),
    ...(options.headers || {}),
  };

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 8000);

    const res = await fetch(url, {
      ...options,
      headers,
      signal: controller.signal,
    });
    clearTimeout(timeoutId);

    if (res.ok) {
      return (await res.json()) as T;
    }

    if (res.status === 404 && url.startsWith('/api/v1')) {
      const directRes = await fetch(directUrl, { ...options, headers });
      if (directRes.ok) {
        return (await directRes.json()) as T;
      }
    }

    const errBody = await res.text();
    let errDetail = `HTTP ${res.status}: ${res.statusText}`;
    try {
      const parsed = JSON.parse(errBody) as { detail?: string };
      if (parsed.detail) errDetail = parsed.detail;
    } catch {
      // use errDetail
    }
    throw new Error(errDetail);
  } catch (err: unknown) {
    try {
      const directRes = await fetch(directUrl, { ...options, headers });
      if (directRes.ok) {
        return (await directRes.json()) as T;
      }
    } catch {
      // fallback
    }
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(message, { cause: err });
  }
}

// ----------------------------------------------------------------------
// Raw Data Structures for Safe Deserialization
// ----------------------------------------------------------------------

interface RawProject {
  id: string;
  name: string;
  slug: string;
  created_at: string;
  api_key?: string;
  api_key_prefix?: string;
}

interface RawEnvironment {
  id: string;
  project_id: string;
  name: string;
  slug: string;
  created_at: string;
}

interface RawSpanEvent {
  timestamp?: string;
  created_at?: string;
  name?: string;
  data?: Record<string, unknown>;
  attributes?: Record<string, unknown>;
}

interface RawSpan {
  id: string;
  trace_id?: string;
  traceId?: string;
  parent_span_id?: string | null;
  parentSpanId?: string | null;
  name?: string;
  span_type?: string;
  spanType?: string;
  status?: string;
  start_time?: string;
  startTime?: string;
  end_time?: string | null;
  endTime?: string | null;
  duration_ms?: number;
  durationMs?: number;
  input_payload?: Record<string, unknown> | string | null;
  inputPayload?: Record<string, unknown> | string | null;
  output_payload?: Record<string, unknown> | string | null;
  outputPayload?: Record<string, unknown> | string | null;
  error_message?: string | null;
  errorMessage?: string | null;
  attributes?: Record<string, unknown>;
  events?: RawSpanEvent[];
  children?: RawSpan[];
}

interface RawTrace {
  id: string;
  project_id?: string;
  projectId?: string;
  environment_id?: string;
  environmentId?: string;
  agent_name?: string;
  agentName?: string;
  session_id?: string | null;
  sessionId?: string | null;
  status?: string;
  start_time?: string;
  startTime?: string;
  end_time?: string | null;
  endTime?: string | null;
  duration_ms?: number;
  durationMs?: number;
  total_tokens?: number;
  totalTokens?: number;
  cost_usd?: number | string;
  costUsd?: number | string;
  root_span_name?: string;
  rootSpanName?: string;
  span_count?: number;
  spanCount?: number;
  has_failures?: boolean;
  hasFailures?: boolean;
  spans?: RawSpan[];
}

interface RawFinding {
  id: string;
  trace_id?: string;
  traceId?: string;
  span_id?: string | null;
  spanId?: string | null;
  span_name?: string | null;
  spanName?: string | null;
  rule_type?: FailureRuleType;
  ruleType?: FailureRuleType;
  severity?: FailureSeverity;
  created_at?: string;
  timestamp?: string;
  evidence_summary?: string;
  evidenceSummary?: string;
  evidence_data?: Record<string, unknown>;
  evidenceData?: Record<string, unknown>;
  fingerprint?: string;
}

interface RawPaginated<T> {
  items?: T[];
  total?: number;
  limit?: number;
  offset?: number;
}

interface RawOverview {
  total_executions?: number;
  failed_executions?: number;
  error_rate?: number;
  p95_latency_ms?: number | null;
  avg_duration_ms?: number | null;
  total_tokens?: number;
  estimated_cost_usd?: number | string;
  is_telemetry_standby?: boolean;
}

interface RawActivityItem {
  time: string;
  total: number;
  failed: number;
  success: number;
}

interface RawRuleItem {
  id: FailureRuleType;
  name: string;
  description: string;
  condition: string;
  severity: FailureSeverity;
  count?: number;
  active_threshold_ms?: number | null;
}

interface RawAgentMetric {
  agent_name: string;
  executions: number;
  error_rate: number;
  avg_duration_ms: number;
  total_tokens: number;
}

interface RawToolMetric {
  tool_name: string;
  calls: number;
  error_rate: number;
  avg_duration_ms: number;
}

interface RawPerformanceResponse {
  agents?: RawAgentMetric[];
  tools?: RawToolMetric[];
}

// ----------------------------------------------------------------------
// Normalization Mappers
// ----------------------------------------------------------------------

function mapSpanEvent(raw: RawSpanEvent): SpanEvent {
  return {
    timestamp: raw.timestamp || raw.created_at || new Date().toISOString(),
    name: raw.name || '',
    data: raw.data || raw.attributes || {},
  };
}

export function mapSpan(raw: RawSpan): Span {
  return {
    id: raw.id,
    traceId: raw.trace_id || raw.traceId || '',
    parentSpanId: raw.parent_span_id ?? raw.parentSpanId ?? null,
    name: raw.name || 'unnamed_span',
    spanType: raw.span_type || raw.spanType || 'AGENT_STEP',
    status: raw.status || 'OK',
    startTime: raw.start_time || raw.startTime || new Date().toISOString(),
    endTime: raw.end_time ?? raw.endTime ?? null,
    durationMs: raw.duration_ms ?? raw.durationMs ?? 0,
    inputPayload: raw.input_payload ?? raw.inputPayload ?? null,
    outputPayload: raw.output_payload ?? raw.outputPayload ?? null,
    errorMessage: raw.error_message ?? raw.errorMessage ?? null,
    attributes: raw.attributes || {},
    events: Array.isArray(raw.events) ? raw.events.map(mapSpanEvent) : [],
    children: Array.isArray(raw.children) ? raw.children.map(mapSpan) : undefined,
  };
}

export function mapTrace(raw: RawTrace): Trace {
  const spansList: Span[] = Array.isArray(raw.spans)
    ? raw.spans.map(mapSpan)
    : [];

  return {
    id: raw.id,
    projectId: raw.project_id || raw.projectId,
    environmentId: raw.environment_id || raw.environmentId,
    agentName: raw.agent_name || raw.agentName || 'autonomous_agent',
    sessionId: raw.session_id ?? raw.sessionId ?? null,
    status: raw.status || 'SUCCESS',
    startTime: raw.start_time || raw.startTime || new Date().toISOString(),
    endTime: raw.end_time ?? raw.endTime ?? null,
    durationMs: raw.duration_ms ?? raw.durationMs ?? 0,
    totalTokens: raw.total_tokens ?? raw.totalTokens ?? 0,
    costUsd: Number(raw.cost_usd ?? raw.costUsd ?? 0),
    rootSpanName: raw.root_span_name || raw.rootSpanName || 'agent_execution',
    spanCount: raw.span_count ?? raw.spanCount ?? spansList.length,
    hasFailures: raw.has_failures ?? raw.hasFailures ?? false,
    spans: spansList,
  };
}

export function mapFinding(raw: RawFinding): FailureViolation {
  return {
    id: raw.id,
    traceId: raw.trace_id || raw.traceId || '',
    spanId: raw.span_id || raw.spanId || '',
    spanName: raw.span_name || raw.spanName || (raw.span_id ? 'Span ' + raw.span_id.slice(0, 8) : 'Trace Root'),
    ruleType: raw.rule_type || raw.ruleType || 'FAILED_SPAN',
    severity: raw.severity || 'WARNING',
    timestamp: raw.created_at || raw.timestamp || new Date().toISOString(),
    evidenceSummary: raw.evidence_summary || raw.evidenceSummary || '',
    evidenceData: raw.evidence_data || raw.evidenceData || {},
    fingerprint: raw.fingerprint,
  };
}

// ----------------------------------------------------------------------
// Backend Health
// ----------------------------------------------------------------------

export async function fetchBackendHealth(): Promise<BackendConnectionState> {
  const startTime = performance.now();

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3500);

    const response = await fetch(PRIMARY_HEALTH_URL, {
      method: 'GET',
      headers: { 'Accept': 'application/json' },
      signal: controller.signal,
    });
    clearTimeout(timeoutId);

    const latencyMs = Math.round(performance.now() - startTime);

    if (response.ok) {
      const data: BackendHealthResponse = await response.json();
      return {
        isConnected: true,
        isLoading: false,
        lastChecked: new Date(),
        latencyMs,
        data,
        errorMessage: null,
      };
    } else {
      return {
        isConnected: false,
        isLoading: false,
        lastChecked: new Date(),
        latencyMs,
        data: null,
        errorMessage: `Backend returned HTTP ${response.status}: ${response.statusText}`,
      };
    }
  } catch (primaryErr) {
    try {
      const fallbackStart = performance.now();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);

      const response = await fetch(FALLBACK_HEALTH_URL, {
        method: 'GET',
        headers: { 'Accept': 'application/json' },
        signal: controller.signal,
      });
      clearTimeout(timeoutId);
      const latencyMs = Math.round(performance.now() - fallbackStart);

      if (response.ok) {
        const data: BackendHealthResponse = await response.json();
        return {
          isConnected: true,
          isLoading: false,
          lastChecked: new Date(),
          latencyMs,
          data,
          errorMessage: null,
        };
      }
    } catch {
      // Both failed
    }

    const message = primaryErr instanceof Error
      ? primaryErr.name === 'AbortError'
        ? 'Connection timed out after 3.5s'
        : primaryErr.message
      : 'Failed to connect to FastAPI backend at http://localhost:8000';

    return {
      isConnected: false,
      isLoading: false,
      lastChecked: new Date(),
      latencyMs: null,
      data: null,
      errorMessage: message,
    };
  }
}

// ----------------------------------------------------------------------
// Projects API
// ----------------------------------------------------------------------

export async function fetchProjects(): Promise<Project[]> {
  const data = await requestJson<RawProject[]>('/projects');
  return data.map((p) => ({
    id: p.id,
    name: p.name,
    slug: p.slug,
    createdAt: p.created_at,
    apiKeyPrefix: p.api_key_prefix,
  }));
}

export async function createProject(payload: { name: string; slug?: string }): Promise<Project> {
  const p = await requestJson<RawProject>('/projects', {
    method: 'POST',
    body: JSON.stringify(payload),
  });
  return {
    id: p.id,
    name: p.name,
    slug: p.slug,
    createdAt: p.created_at,
    apiKey: p.api_key,
    apiKeyPrefix: p.api_key_prefix,
  };
}

export async function getProject(projectId: string): Promise<Project> {
  const p = await requestJson<RawProject>(`/projects/${projectId}`);
  return {
    id: p.id,
    name: p.name,
    slug: p.slug,
    createdAt: p.created_at,
    apiKeyPrefix: p.api_key_prefix,
  };
}

export async function regenerateApiKey(projectId: string): Promise<{ apiKey: string; apiKeyPrefix: string }> {
  const res = await requestJson<{ api_key: string; api_key_prefix: string }>(`/projects/${projectId}/api-key`, {
    method: 'POST',
  });
  return {
    apiKey: res.api_key,
    apiKeyPrefix: res.api_key_prefix,
  };
}

// ----------------------------------------------------------------------
// Environments API
// ----------------------------------------------------------------------

export async function fetchEnvironments(projectId?: string): Promise<EnvironmentInfo[]> {
  const q = projectId ? `?project_id=${projectId}` : '';
  const data = await requestJson<RawEnvironment[]>(`/environments${q}`);
  return data.map((e) => ({
    id: e.id,
    projectId: e.project_id,
    name: e.name,
    slug: e.slug,
    createdAt: e.created_at,
  }));
}

// ----------------------------------------------------------------------
// Traces API
// ----------------------------------------------------------------------

export interface TraceQueryParams {
  project_id?: string;
  environment?: string;
  status?: string;
  has_failures?: boolean;
  agent_name?: string;
  search?: string;
  time_range?: string;
  limit?: number;
  offset?: number;
}

export async function fetchTraces(
  params: TraceQueryParams = {}
): Promise<{ items: Trace[]; total: number; limit: number; offset: number }> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.status && params.status !== 'ALL') query.set('status', params.status);
  if (params.has_failures !== undefined) query.set('has_failures', String(params.has_failures));
  if (params.agent_name) query.set('agent_name', params.agent_name);
  if (params.search) query.set('search', params.search);
  if (params.time_range) query.set('time_range', params.time_range);
  if (params.limit !== undefined) query.set('limit', String(params.limit));
  if (params.offset !== undefined) query.set('offset', String(params.offset));

  const qs = query.toString();
  const res = await requestJson<RawPaginated<RawTrace>>(`/traces${qs ? `?${qs}` : ''}`);
  return {
    items: Array.isArray(res.items) ? res.items.map(mapTrace) : [],
    total: res.total || 0,
    limit: res.limit || 50,
    offset: res.offset || 0,
  };
}

export async function fetchTraceDetail(traceId: string): Promise<Trace> {
  const raw = await requestJson<RawTrace>(`/traces/${traceId}`);
  return mapTrace(raw);
}

export async function fetchTraceSpans(traceId: string): Promise<Span[]> {
  const rawList = await requestJson<RawSpan[]>(`/traces/${traceId}/spans`);
  return rawList.map(mapSpan);
}

export async function fetchTraceFailures(traceId: string): Promise<FailureViolation[]> {
  const rawList = await requestJson<RawFinding[]>(`/traces/${traceId}/failures`);
  return rawList.map(mapFinding);
}

// ----------------------------------------------------------------------
// Spans API
// ----------------------------------------------------------------------

export async function fetchSpanDetail(spanId: string): Promise<Span> {
  const raw = await requestJson<RawSpan>(`/spans/${spanId}`);
  return mapSpan(raw);
}

export async function fetchSpanEvents(spanId: string): Promise<SpanEvent[]> {
  const raw = await requestJson<RawSpanEvent[]>(`/spans/${spanId}/events`);
  return raw.map(mapSpanEvent);
}

// ----------------------------------------------------------------------
// Failure Findings API
// ----------------------------------------------------------------------

export interface FailureQueryParams {
  project_id?: string;
  environment?: string;
  severity?: string;
  rule_type?: string;
  time_range?: string;
  limit?: number;
  offset?: number;
}

export async function fetchFailures(
  params: FailureQueryParams = {}
): Promise<{ items: FailureViolation[]; total: number; limit: number; offset: number }> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.severity && params.severity !== 'ALL') query.set('severity', params.severity);
  if (params.rule_type) query.set('rule_type', params.rule_type);
  if (params.time_range) query.set('time_range', params.time_range);
  if (params.limit !== undefined) query.set('limit', String(params.limit));
  if (params.offset !== undefined) query.set('offset', String(params.offset));

  const qs = query.toString();
  const res = await requestJson<RawPaginated<RawFinding>>(`/failures${qs ? `?${qs}` : ''}`);
  return {
    items: Array.isArray(res.items) ? res.items.map(mapFinding) : [],
    total: res.total || 0,
    limit: res.limit || 50,
    offset: res.offset || 0,
  };
}

export async function fetchFailureDetail(findingId: string): Promise<FailureViolation> {
  const raw = await requestJson<RawFinding>(`/failures/${findingId}`);
  return mapFinding(raw);
}

// ----------------------------------------------------------------------
// Analytics API
// ----------------------------------------------------------------------

export interface AnalyticsFilterParams {
  project_id?: string;
  environment?: string;
  time_range?: string;
}

export async function fetchAnalyticsOverview(
  params: AnalyticsFilterParams = {}
): Promise<AnalyticsOverview> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.time_range) query.set('time_range', params.time_range);

  const qs = query.toString();
  const raw = await requestJson<RawOverview>(`/analytics/overview${qs ? `?${qs}` : ''}`);
  return {
    totalExecutions: raw.total_executions ?? 0,
    failedExecutions: raw.failed_executions ?? 0,
    errorRate: raw.error_rate ?? 0,
    p95LatencyMs: raw.p95_latency_ms ?? null,
    avgDurationMs: raw.avg_duration_ms ?? null,
    totalTokens: raw.total_tokens ?? 0,
    estimatedCostUsd: Number(raw.estimated_cost_usd ?? 0),
    isTelemetryStandby: Boolean(raw.is_telemetry_standby),
  };
}

export async function fetchAnalyticsActivity(
  params: AnalyticsFilterParams = {}
): Promise<ActivityDataPoint[]> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.time_range) query.set('time_range', params.time_range);

  const qs = query.toString();
  const raw = await requestJson<{ items?: RawActivityItem[] }>(`/analytics/activity${qs ? `?${qs}` : ''}`);
  const items = Array.isArray(raw.items) ? raw.items : [];
  return items.map((pt) => ({
    time: pt.time,
    total: pt.total,
    failed: pt.failed,
    success: pt.success,
  }));
}

export async function fetchAnalyticsRules(
  params: AnalyticsFilterParams = {}
): Promise<RuleMetric[]> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.time_range) query.set('time_range', params.time_range);

  const qs = query.toString();
  const raw = await requestJson<{ items?: RawRuleItem[] }>(`/analytics/rules${qs ? `?${qs}` : ''}`);
  const items = Array.isArray(raw.items) ? raw.items : [];
  return items.map((r) => ({
    id: r.id,
    name: r.name,
    description: r.description,
    condition: r.condition,
    severity: r.severity,
    count: r.count ?? 0,
    activeThresholdMs: r.active_threshold_ms ?? null,
  }));
}

export async function fetchAnalyticsPerformance(
  params: AnalyticsFilterParams = {}
): Promise<{ agents: AgentMetric[]; tools: ToolMetric[] }> {
  const query = new URLSearchParams();
  if (params.project_id) query.set('project_id', params.project_id);
  if (params.environment) query.set('environment', params.environment);
  if (params.time_range) query.set('time_range', params.time_range);

  const qs = query.toString();
  const raw = await requestJson<RawPerformanceResponse>(`/analytics/performance${qs ? `?${qs}` : ''}`);
  return {
    agents: (raw.agents || []).map((a) => ({
      agentName: a.agent_name,
      executions: a.executions,
      errorRate: a.error_rate,
      avgDurationMs: a.avg_duration_ms,
      totalTokens: a.total_tokens,
    })),
    tools: (raw.tools || []).map((t) => ({
      toolName: t.tool_name,
      calls: t.calls,
      errorRate: t.error_rate,
      avgDurationMs: t.avg_duration_ms,
    })),
  };
}
