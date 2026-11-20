import React, { useState } from 'react';
import {
  Settings,
  Terminal,
  Copy,
  Check,
  ExternalLink,
  Save
} from 'lucide-react';
import { useApp } from '../../context/useApp';

export const SettingsView: React.FC = () => {
  const { currentProject, environment } = useApp();
  const [activeTab, setActiveTab] = useState<'general' | 'projects' | 'sdk' | 'privacy' | 'account'>('general');

  const [apiEndpoint, setApiEndpoint] = useState('http://localhost:8000');
  const [pollInterval, setPollInterval] = useState('15');
  const [isSaved, setIsSaved] = useState(false);
  const [copiedSdk, setCopiedSdk] = useState(false);

  const sdkCode = `# AgentLens Python SDK Configuration
export AGENTLENS_ENDPOINT="${apiEndpoint}"
export AGENTLENS_ENVIRONMENT="${environment}"
export AGENTLENS_PROJECT_ID="${currentProject.id}"
export AGENTLENS_BATCH_SIZE=25
export AGENTLENS_FLUSH_INTERVAL_MS=1000`;

  const handleSaveGeneral = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2000);
  };

  const handleCopySdk = () => {
    navigator.clipboard.writeText(sdkCode);
    setCopiedSdk(true);
    setTimeout(() => setCopiedSdk(false), 2000);
  };

  return (
    <div className="space-y-5 animate-in fade-in duration-150 max-w-5xl">
      {/* Top Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded-md bg-[#171c19] text-[#b8f56a] border border-[#252d28]">
              <Settings className="h-4 w-4" />
            </div>
            <h1 className="text-base font-semibold text-[#f5f7f5] font-mono tracking-tight">
              Platform & Environment Settings
            </h1>
          </div>
        </div>
      </div>

      {/* Settings Navigation Tabs */}
      <div className="flex items-center gap-1 border-b border-[#252d28] pb-2 overflow-x-auto text-xs font-mono">
        {[
          { id: 'general', label: 'General' },
          { id: 'projects', label: 'Projects' },
          { id: 'sdk', label: 'SDK Configuration' },
          { id: 'privacy', label: 'Data & Privacy' },
          { id: 'account', label: 'Account & System' },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as typeof activeTab)}
            className={`px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap ${
              activeTab === tab.id
                ? 'bg-[#1c221e] text-[#f5f7f5] border border-[#303a33] font-medium shadow-xs'
                : 'text-[#929b94] hover:text-[#f5f7f5] hover:bg-[#171c19]'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab: General */}
      {activeTab === 'general' && (
        <form onSubmit={handleSaveGeneral} className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-6">
          <div className="border-b border-[#252d28] pb-4">
            <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">Backend Communication</h2>
            <p className="text-xs text-[#929b94] mt-0.5">
              Specify the target FastAPI daemon address and client health check frequency.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs font-mono">
            <div className="space-y-1.5">
              <label className="text-[#f5f7f5] font-medium">FastAPI Endpoint URL</label>
              <input
                type="text"
                value={apiEndpoint}
                onChange={(e) => setApiEndpoint(e.target.value)}
                className="w-full px-3 py-2 bg-[#171c19] border border-[#252d28] rounded-lg text-[#f5f7f5] focus:outline-hidden focus:border-[#b8f56a]/60 focus:ring-1 focus:ring-[#b8f56a]/30 transition-all"
              />
              <span className="text-[10px] text-[#626b64] block">Default local address: http://localhost:8000</span>
            </div>

            <div className="space-y-1.5">
              <label className="text-[#f5f7f5] font-medium">Health Heartbeat Interval</label>
              <select
                value={pollInterval}
                onChange={(e) => setPollInterval(e.target.value)}
                className="w-full px-3 py-2 bg-[#171c19] border border-[#252d28] rounded-lg text-[#f5f7f5] focus:outline-hidden focus:border-[#b8f56a]/60 focus:ring-1 focus:ring-[#b8f56a]/30 transition-all"
              >
                <option value="10">10 seconds</option>
                <option value="15">15 seconds (Recommended)</option>
                <option value="30">30 seconds</option>
                <option value="60">60 seconds</option>
              </select>
              <span className="text-[10px] text-[#626b64] block">How often the frontend polls GET /health</span>
            </div>
          </div>

          <div className="pt-4 border-t border-[#252d28] flex items-center justify-between">
            <button
              type="submit"
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-[#b8f56a] hover:bg-[#b8f56a]/90 text-[#090b0a] text-xs font-mono font-semibold transition-colors shadow-xs"
            >
              <Save className="h-3.5 w-3.5" />
              <span>Save General Preferences</span>
            </button>

            {isSaved && (
              <span className="inline-flex items-center gap-1 text-xs font-mono text-[#67c98a]">
                <Check className="h-3.5 w-3.5" />
                <span>Preferences saved locally</span>
              </span>
            )}
          </div>
        </form>
      )}

      {/* Tab: Projects */}
      {activeTab === 'projects' && (
        <div className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-5">
          <div className="border-b border-[#252d28] pb-4">
            <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">Workspace Projects</h2>
            <p className="text-xs text-[#929b94] mt-0.5">
              Isolated monitoring boundaries for instrumented multi-agent applications.
            </p>
          </div>

          <div className="space-y-3 font-mono text-xs">
            <div className="p-4 rounded-xl bg-[#171c19] border border-[#252d28] flex items-center justify-between">
              <div className="space-y-1">
                <div className="flex items-center gap-2">
                  <span className="font-semibold text-[#f5f7f5]">{currentProject.name}</span>
                  <span className="px-2 py-0.5 rounded bg-[#b8f56a]/15 text-[#b8f56a] border border-[#b8f56a]/30 text-[10px]">Active</span>
                </div>
                <div className="text-[11px] text-[#626b64]">ID: {currentProject.id} &bull; Slug: {currentProject.slug}</div>
              </div>

              <div className="text-[11px] text-[#929b94]">Local Environment</div>
            </div>
          </div>
        </div>
      )}

      {/* Tab: SDK Configuration */}
      {activeTab === 'sdk' && (
        <div className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-5">
          <div className="border-b border-[#252d28] pb-4">
            <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">Python SDK Environment Flags</h2>
            <p className="text-xs text-[#929b94] mt-0.5">
              Environment variables to export in your agent execution environment to route spans to this dashboard.
            </p>
          </div>

          <div className="rounded-xl bg-[#0c100d] border border-[#252d28] overflow-hidden font-mono text-xs">
            <div className="p-3 bg-[#171c19] border-b border-[#252d28] flex items-center justify-between text-[#929b94]">
              <div className="flex items-center gap-2">
                <Terminal className="h-3.5 w-3.5 text-[#6bc8c1]" />
                <span className="text-[#f5f7f5]">agentlens_environment.sh</span>
              </div>
              <button
                onClick={handleCopySdk}
                className="flex items-center gap-1 px-2.5 py-1 rounded bg-[#1c221e] hover:bg-[#252d28] text-[#f5f7f5] border border-[#303a33] transition-colors"
              >
                {copiedSdk ? <Check className="h-3 w-3 text-[#67c98a]" /> : <Copy className="h-3 w-3" />}
                <span className="text-[10px]">{copiedSdk ? 'Copied' : 'Copy Variables'}</span>
              </button>
            </div>
            <pre className="p-4 text-[#6bc8c1] leading-relaxed overflow-x-auto">
              <code>{sdkCode}</code>
            </pre>
          </div>
        </div>
      )}

      {/* Tab: Data & Privacy */}
      {activeTab === 'privacy' && (
        <div className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-5">
          <div className="border-b border-[#252d28] pb-4">
            <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">Data Sanitization & Privacy</h2>
            <p className="text-xs text-[#929b94] mt-0.5">
              Configure telemetry masking to sanitize sensitive tokens, keys, and PII from prompts and completions.
            </p>
          </div>

          <div className="space-y-3 font-mono text-xs">
            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] flex items-start justify-between gap-3">
              <div>
                <h3 className="font-semibold text-[#f5f7f5]">API Key Masking</h3>
                <p className="text-[11px] text-[#929b94] font-sans mt-0.5">
                  Automatically scrubs strings matching known API key patterns (OpenAI, Anthropic, Google, AWS).
                </p>
              </div>
              <span className="px-2 py-0.5 rounded bg-[#67c98a]/15 text-[#67c98a] border border-[#67c98a]/30 text-[10px]">Active</span>
            </div>

            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] flex items-start justify-between gap-3">
              <div>
                <h3 className="font-semibold text-[#f5f7f5]">Payload Truncation</h3>
                <p className="text-[11px] text-[#929b94] font-sans mt-0.5">
                  Limits maximum span input/output payload size to 64KB to avoid memory exhaustion on large document analysis.
                </p>
              </div>
              <span className="px-2 py-0.5 rounded bg-[#1c221e] text-[#929b94] border border-[#303a33] text-[10px]">64 KB Limit</span>
            </div>
          </div>
        </div>
      )}

      {/* Tab: Account & System */}
      {activeTab === 'account' && (
        <div className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-5">
          <div className="border-b border-[#252d28] pb-4">
            <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">System & Local Instance</h2>
            <p className="text-xs text-[#929b94] mt-0.5">
              Local environment diagnostics and version metadata.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs font-mono">
            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] space-y-1">
              <span className="text-[10px] text-[#626b64] uppercase font-semibold">Platform Version</span>
              <span className="text-[#f5f7f5] font-semibold block">AgentLens 0.1.0-alpha</span>
            </div>

            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] space-y-1">
              <span className="text-[10px] text-[#626b64] uppercase font-semibold">Frontend Architecture</span>
              <span className="text-[#f5f7f5] font-semibold block">React 19 + TypeScript + Vite + Tailwind v4</span>
            </div>

            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] space-y-1">
              <span className="text-[10px] text-[#626b64] uppercase font-semibold">Backend Server</span>
              <span className="text-[#f5f7f5] font-semibold block">FastAPI + Uvicorn (Port 8000)</span>
            </div>

            <div className="p-3.5 rounded-xl bg-[#171c19] border border-[#252d28] space-y-1">
              <span className="text-[10px] text-[#626b64] uppercase font-semibold">Repository</span>
              <a
                href="https://github.com/Rhythmuppal18/AgentLens"
                target="_blank"
                rel="noreferrer"
                className="text-[#b8f56a] hover:underline flex items-center gap-1 font-semibold"
              >
                <span>github.com/Rhythmuppal18/AgentLens</span>
                <ExternalLink className="h-3 w-3" />
              </a>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
