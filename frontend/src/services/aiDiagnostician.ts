import type { FailureViolation, FailureRuleType } from '../types';

export interface AiDiagnosisResult {
  headline: string;
  whatHappened: string;
  rootCause: string;
  impactLevel: 'CRITICAL' | 'HIGH' | 'MODERATE';
  impactDescription: string;
  recommendedPromptFix: string;
  recommendedCodeFix: string;
  confidenceScore: number;
}

export function generateAiDiagnosis(violation: FailureViolation): AiDiagnosisResult {
  const spanName = violation.spanName || 'unknown_operation';
  const ruleType = violation.ruleType as FailureRuleType;
  const errorMsg = (violation.evidenceData?.error_message as string) || 
                   (violation.evidenceData?.error as string) || 
                   violation.evidenceSummary || 
                   'Unhandled runtime error';

  switch (ruleType) {
    case 'REPEATED_TOOL_CALL':
      return {
        headline: `Reasoning Deadlock in '${spanName}'`,
        whatHappened: `The agent called tool '${spanName}' repeatedly with identical input parameters across consecutive execution turns. It received identical responses and continued looping without making progress.`,
        rootCause: `Context interpretation failure: The LLM was unable to extract actionable answers from the prior tool output. Because the system prompt lacked loop-breaking instructions, the agent fell into an autonomous retry loop.`,
        impactLevel: 'HIGH',
        impactDescription: 'Wastes token quota rapidly, stalls user workflow, and risks runaway API costs.',
        recommendedPromptFix: `Add this guardrail to your Agent's System Prompt:

"TOOL USAGE GUARDRAILS:
1. Always check your execution history before calling a tool.
2. If you have already invoked '${spanName}' with identical arguments and received an error or unsatisfactory answer, DO NOT call it again with the same parameters.
3. Instead, synthesize the best available answer or explicitly ask the user for clarification."`,
        recommendedCodeFix: `# Python SDK Guardrail: Use AgentLens input hash check to break loops
from agentlens.privacy import compute_canonical_input_hash

seen_hashes = set()

def call_${spanName.replace(/[^a-zA-Z0-9_]/g, '_')}(**kwargs):
    h = compute_canonical_input_hash(kwargs)
    if h in seen_hashes:
        raise ValueError(f"Prevented duplicate loop call to ${spanName}")
    seen_hashes.add(h)
    # execute tool...`,
        confidenceScore: 98,
      };

    case 'FAILED_SPAN':
      return {
        headline: `Unhandled Exception in '${spanName}'`,
        whatHappened: `The span terminated with status ERROR due to: "${errorMsg}". The exception was not caught or gracefully handled by the tool wrapper.`,
        rootCause: `External service failure or missing schema validation. The external dependency failed, and the agentic runtime had no try/catch fallback to report the failure gracefully to the LLM.`,
        impactLevel: 'CRITICAL',
        impactDescription: 'Halts the entire trace workflow abruptly, resulting in a failed task for the end user.',
        recommendedPromptFix: `Add this error-handling instruction to your Agent's System Prompt:

"ERROR HANDLING PROTOCOL:
If '${spanName}' fails or returns an error, do not crash the workflow. 
Acknowledge that '${spanName}' is temporarily unavailable and attempt fallback tool execution or notify the user."`,
        recommendedCodeFix: `# Python SDK Guardrail: Graceful error recovery
try:
    with trace.span("${spanName}", span_type="TOOL_CALL") as span:
        result = execute_${spanName.replace(/[^a-zA-Z0-9_]/g, '_')}()
        span.set_output({"result": result})
except Exception as exc:
    # Set status to ERROR in telemetry, but return a safe fallback message to the agent loop
    return {"status": "error", "message": f"${spanName} unavailable: {exc}"}`,
        confidenceScore: 96,
      };

    case 'EXCESSIVE_RETRIES':
      return {
        headline: `Retry Storm Threshold Exceeded on '${spanName}'`,
        whatHappened: `The operation was retried more than the safety threshold (>3 times) without succeeding.`,
        rootCause: `Persistent upstream rejection or rate-limiting (HTTP 429/503). Retrying immediately without exponential backoff or backoff jitter worsened service starvation.`,
        impactLevel: 'HIGH',
        impactDescription: 'Spikes latency, exhausts upstream API rate-limits, and delays agent response.',
        recommendedPromptFix: `Add this retry ceiling instruction to your Agent's System Prompt:

"RETRY BUDGET:
You may retry a failing action at most 2 times. If it fails after 2 attempts, declare the tool unavailable and switch to a secondary strategy."`,
        recommendedCodeFix: `# Python SDK Guardrail: Bounded exponential backoff with jitter
import time, random

def resilient_call(max_retries=2):
    for attempt in range(max_retries):
        try:
            return execute_operation()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            time.sleep((2 ** attempt) + random.uniform(0.1, 0.5))`,
        confidenceScore: 94,
      };

    case 'SLOW_SPAN':
      return {
        headline: `Latency SLA Breach on '${spanName}'`,
        whatHappened: `Execution duration exceeded acceptable latency budget (SLA threshold breached).`,
        rootCause: `Over-fetching large context payloads, cold starts, or slow third-party API response without streaming or chunking.`,
        impactLevel: 'MODERATE',
        impactDescription: 'Degrades real-time user experience and increases chances of downstream timeout cascade.',
        recommendedPromptFix: `Add this efficiency constraint to your Agent's System Prompt:

"LATENCY OPTIMIZATION:
Request only minimal necessary fields from '${spanName}'. Avoid requesting full raw documents if a 1-paragraph summary satisfies the goal."`,
        recommendedCodeFix: `# Python SDK Guardrail: Strict client timeout
import urllib.request

req = urllib.request.Request(endpoint, headers=headers)
# Bound execution strictly to prevent long-tail stalls
with urllib.request.urlopen(req, timeout=4.0) as res:
    data = res.read()`,
        confidenceScore: 91,
      };

    case 'EMPTY_TOOL_RESULT':
    default:
      return {
        headline: `Context Starvation via Empty Output from '${spanName}'`,
        whatHappened: `The tool '${spanName}' completed with exit status 0 (Success), but returned an empty response (null, empty dictionary, or 0 bytes).`,
        rootCause: `Empty payload starvation: When a tool returns empty data, the downstream LLM receives no grounding context, which forces it to either hallucinate answers or endlessly retry the query.`,
        impactLevel: 'HIGH',
        impactDescription: 'Primary trigger for model hallucinations and repetitive query loops.',
        recommendedPromptFix: `Add this grounding rule to your Agent's System Prompt:

"EMPTY RESULT GROUNDING:
If a tool returns an empty result (such as no search results or 0 records found), explicitly treat it as 'no data exists'. DO NOT invent or assume facts. Inform the user that no matching records were found."`,
        recommendedCodeFix: `# Python SDK Guardrail: Guard against empty payload propagation
output = fetch_data()
if not output:
    return {"status": "empty", "message": "No records found matching criteria", "count": 0}
return output`,
        confidenceScore: 95,
      };
  }
}
