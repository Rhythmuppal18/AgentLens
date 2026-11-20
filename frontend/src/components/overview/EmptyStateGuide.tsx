import React, { useState } from 'react';
import {
  Terminal,
  Copy,
  Check,
  Cpu
} from 'lucide-react';

export const EmptyStateGuide: React.FC = () => {
  const [copied, setCopied] = useState(false);

  const sampleCode = `# Step 1: Install planned agentlens instrumentation package
# pip install agentlens-sdk (Coming in Stage 4)

import os
from agentlens import tracer

# Configure AgentLens endpoint (pointing to running FastAPI server)
os.environ["AGENTLENS_ENDPOINT"] = "http://localhost:8000"

@tracer.trace(name="ResearchAnalystAgent")
def execute_agent_loop(query: str):
    # AgentLens automatically tracks timing, prompts, tools and errors
    with tracer.span("analyze_query", span_type="reasoning") as span:
        plan = reason_about(query)
        span.set_attribute("plan_steps", len(plan))

    for step in plan:
        with tracer.span("execute_tool", span_type="tool_call") as tool_span:
            result = call_tool(step.tool, step.args)
            tool_span.set_attribute("result_bytes", len(result))

    return "Analysis complete."`;

  const handleCopy = () => {
    navigator.clipboard.writeText(sampleCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="p-6 rounded-xl bg-[#0F172A] border border-slate-800 space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-lg bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
            <Cpu className="h-5 w-5" />
          </div>
          <div>
            <h2 className="text-sm font-semibold text-slate-100 font-mono uppercase tracking-wider">
              Agent Telemetry Instrumentation Guide
            </h2>
            <p className="text-xs text-slate-400 mt-0.5">
              Connect your AI agent runtime to stream traces, LLM calls, and tool execution evidence.
            </p>
          </div>
        </div>

        <span className="px-2.5 py-1 text-xs font-mono font-medium rounded-md bg-amber-500/10 text-amber-400 border border-amber-500/30 w-fit">
          SDK in Development (Stage 4)
        </span>
      </div>

      {/* 3 Step Process */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs font-mono">
        <div className="p-4 rounded-lg bg-[#0B0F17] border border-slate-800 space-y-2">
          <div className="flex items-center gap-2 text-violet-400 font-semibold">
            <span className="h-5 w-5 rounded-full bg-violet-500/20 flex items-center justify-center text-[10px]">1</span>
            <span>Verify Backend</span>
          </div>
          <p className="text-slate-400 text-[11px] font-sans leading-relaxed">
            FastAPI server is operational on <code className="text-violet-300 font-mono">http://localhost:8000</code> ready to accept telemetry batches.
          </p>
        </div>

        <div className="p-4 rounded-lg bg-[#0B0F17] border border-slate-800 space-y-2">
          <div className="flex items-center gap-2 text-violet-400 font-semibold">
            <span className="h-5 w-5 rounded-full bg-violet-500/20 flex items-center justify-center text-[10px]">2</span>
            <span>Instrument Agent Loop</span>
          </div>
          <p className="text-slate-400 text-[11px] font-sans leading-relaxed">
            Wrap agent decision loops, LLM calls, and tools with <code className="text-violet-300 font-mono">@tracer.trace</code> or context managers.
          </p>
        </div>

        <div className="p-4 rounded-lg bg-[#0B0F17] border border-slate-800 space-y-2">
          <div className="flex items-center gap-2 text-violet-400 font-semibold">
            <span className="h-5 w-5 rounded-full bg-violet-500/20 flex items-center justify-center text-[10px]">3</span>
            <span>Debug with Evidence</span>
          </div>
          <p className="text-slate-400 text-[11px] font-sans leading-relaxed">
            Inspect traces, debug loop traps, catch empty tool outputs, and evaluate cost directly in AgentLens.
          </p>
        </div>
      </div>

      {/* Code Snippet Box */}
      <div className="rounded-lg bg-[#0B0F17] border border-slate-800 overflow-hidden">
        <div className="px-4 py-2 bg-slate-900/60 border-b border-slate-800 flex items-center justify-between text-xs font-mono text-slate-400">
          <div className="flex items-center gap-2">
            <Terminal className="h-3.5 w-3.5 text-violet-400" />
            <span>example_agent_instrumentation.py</span>
          </div>
          <button
            onClick={handleCopy}
            className="flex items-center gap-1.5 px-2 py-1 rounded hover:bg-slate-800 text-slate-300 transition-colors"
          >
            {copied ? (
              <>
                <Check className="h-3.5 w-3.5 text-emerald-400" />
                <span className="text-emerald-400 text-[11px]">Copied</span>
              </>
            ) : (
              <>
                <Copy className="h-3.5 w-3.5" />
                <span className="text-[11px]">Copy Snippet</span>
              </>
            )}
          </button>
        </div>

        <pre className="p-4 text-xs font-mono text-slate-300 overflow-x-auto leading-relaxed">
          <code>{sampleCode}</code>
        </pre>
      </div>
    </div>
  );
};
