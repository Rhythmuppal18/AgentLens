import React, { useState } from 'react';
import {
  Settings,
  Terminal,
  Copy,
  Check,
  ExternalLink,
  Save,
  Key,
  RefreshCw,
  Plus,
  FolderGit2
} from 'lucide-react';
import { useApp } from '../../context/useApp';
import { createProject, regenerateApiKey } from '../../services/api';

export const SettingsView: React.FC = () => {
  const { currentProject, setCurrentProject, projects, environment, refreshProjects } = useApp();
  const [activeTab, setActiveTab] = useState<'general' | 'projects' | 'sdk' | 'privacy' | 'account'>('general');

  const [apiEndpoint, setApiEndpoint] = useState('http://localhost:8000');
  const [pollInterval, setPollInterval] = useState('15');
  const [isSaved, setIsSaved] = useState(false);
  const [copiedSdk, setCopiedSdk] = useState(false);

  // API Key management state
  const [revealedApiKey, setRevealedApiKey] = useState<string | null>(currentProject?.apiKey || null);
  const [isRegeneratingKey, setIsRegeneratingKey] = useState(false);
  const [copiedKey, setCopiedKey] = useState(false);

  // New project creation state
  const [newProjectName, setNewProjectName] = useState('');
  const [isCreatingProject, setIsCreatingProject] = useState(false);
  const [createProjectError, setCreateProjectError] = useState<string | null>(null);

  const activeApiKey = revealedApiKey || `${currentProject?.apiKeyPrefix || 'ag_live_'}************************`;

  const sdkCode = `# AgentLens Python SDK Configuration
export AGENTLENS_ENDPOINT="${apiEndpoint}"
export AGENTLENS_API_KEY="${activeApiKey}"
export AGENTLENS_ENVIRONMENT="${environment}"
export AGENTLENS_PROJECT_ID="${currentProject?.id || ''}"
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

  const handleCopyKey = (key: string) => {
    navigator.clipboard.writeText(key);
    setCopiedKey(true);
    setTimeout(() => setCopiedKey(false), 2000);
  };

  const handleRegenerateKey = async (projId: string) => {
    setIsRegeneratingKey(true);
    try {
      const res = await regenerateApiKey(projId);
      setRevealedApiKey(res.apiKey);
      await refreshProjects();
    } catch (err: unknown) {
      alert(err instanceof Error ? err.message : 'Failed to regenerate API key');
    } finally {
      setIsRegeneratingKey(false);
    }
  };

  const handleCreateProject = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newProjectName.trim()) return;
    setIsCreatingProject(true);
    setCreateProjectError(null);
    try {
      const created = await createProject({ name: newProjectName.trim() });
      setNewProjectName('');
      if (created.apiKey) {
        setRevealedApiKey(created.apiKey);
      }
      await refreshProjects();
      setCurrentProject(created);
    } catch (err: unknown) {
      setCreateProjectError(err instanceof Error ? err.message : 'Failed to create project');
    } finally {
      setIsCreatingProject(false);
    }
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
          { id: 'projects', label: 'Projects & Keys' },
          { id: 'sdk', label: 'SDK Configuration' },
          { id: 'privacy', label: 'Data & Privacy' },
          { id: 'account', label: 'Account & System' },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as typeof activeTab)}
            className={`px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap cursor-pointer ${
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
              className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-[#b8f56a] hover:bg-[#b8f56a]/90 text-[#090b0a] text-xs font-mono font-semibold transition-colors shadow-xs cursor-pointer"
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

      {/* Tab: Projects & Keys */}
      {activeTab === 'projects' && (
        <div className="p-6 rounded-xl bg-[#111512] border border-[#252d28] space-y-6">
          <div className="border-b border-[#252d28] pb-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <h2 className="text-sm font-semibold text-[#f5f7f5] font-mono">Workspace Projects & API Keys</h2>
              <p className="text-xs text-[#929b94] mt-0.5">
                Isolated monitoring boundaries and cryptographic ingest credentials.
              </p>
            </div>
          </div>

          {/* New Project Inline Form */}
          <form onSubmit={handleCreateProject} className="p-4 rounded-lg bg-[#171c19] border border-[#252d28] space-y-3 font-mono text-xs">
            <span className="text-[11px] text-[#f5f7f5] font-semibold flex items-center gap-1.5">
              <Plus className="h-3.5 w-3.5 text-[#b8f56a]" />
              <span>Create New Project</span>
            </span>
            <div className="flex flex-col sm:flex-row gap-2">
              <input
                type="text"
                value={newProjectName}
                onChange={(e) => setNewProjectName(e.target.value)}
                placeholder="e.g. Multi-Agent Financial Analyst"
                className="flex-1 px-3 py-1.5 bg-[#0e110f] border border-[#252d28] rounded-md text-[#f5f7f5] placeholder:text-[#626b64] focus:outline-hidden focus:border-[#b8f56a]"
              />
              <button
                type="submit"
                disabled={isCreatingProject || !newProjectName.trim()}
                className="px-4 py-1.5 rounded-md bg-[#b8f56a] hover:bg-[#b8f56a]/90 text-[#090b0a] font-semibold disabled:opacity-50 transition-colors cursor-pointer"
              >
                {isCreatingProject ? 'Creating...' : 'Create Project'}
              </button>
            </div>
            {createProjectError && (
              <p className="text-[10px] text-[#f06f68]">{createProjectError}</p>
            )}
          </form>

          {/* Revealed Plaintext Key Banner (after generation) */}
          {revealedApiKey && (
            <div className="p-4 rounded-lg bg-[#1a1710] border border-[#e5ad55]/40 space-y-2 font-mono text-xs">
              <div className="flex items-center justify-between text-[#e5ad55] font-semibold">
                <div className="flex items-center gap-1.5">
                  <Key className="h-4 w-4" />
                  <span>Newly Generated Ingestion API Key (Save immediately)</span>
                </div>
                <button
                  onClick={() => handleCopyKey(revealedApiKey)}
                  className="flex items-center gap-1 px-2.5 py-1 rounded bg-[#252014] hover:bg-[#332b1a] text-[#e5ad55] border border-[#e5ad55]/30 cursor-pointer"
                >
                  {copiedKey ? <Check className="h-3 w-3 text-[#67c98a]" /> : <Copy className="h-3 w-3" />}
                  <span>{copiedKey ? 'Copied' : 'Copy Key'}</span>
                </button>
              </div>
              <div className="p-2.5 bg-[#0f0e0a] rounded border border-[#e5ad55]/20 text-[#f5f7f5] break-all select-all font-mono text-[11px]">
                {revealedApiKey}
              </div>
              <p className="text-[10px] text-[#9ba69e] font-sans">
                This key is hashed using SHA-256 in PostgreSQL and will not be displayed in plaintext again.
              </p>
            </div>
          )}

          {/* Projects List */}
          <div className="space-y-3 font-mono text-xs">
            {projects.map((proj) => {
              const isActive = proj.id === currentProject?.id;
              return (
                <div
                  key={proj.id}
                  className={`p-4 rounded-xl border transition-all ${
                    isActive
                      ? 'bg-[#171c19] border-[#b8f56a]/40 shadow-xs'
                      : 'bg-[#111512] border-[#252d28] hover:border-[#303a33]'
                  }`}
                >
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <FolderGit2 className="h-4 w-4 text-[#b8f56a]" />
                        <span className="font-semibold text-[#f5f7f5] text-sm">{proj.name}</span>
                        {isActive && (
                          <span className="px-2 py-0.5 rounded bg-[#b8f56a]/15 text-[#b8f56a] border border-[#b8f56a]/30 text-[10px]">
                            Active Project
                          </span>
                        )}
                      </div>
                      <div className="text-[11px] text-[#626b64]">
                        ID: <span className="text-[#929b94]">{proj.id}</span> &bull; Slug: <span className="text-[#929b94]">{proj.slug}</span>
                      </div>
                      <div className="text-[10px] text-[#626b64]">
                        Key Prefix: <code className="text-[#6bc8c1]">{proj.apiKeyPrefix || 'ag_live_'}</code>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      {!isActive && (
                        <button
                          onClick={() => setCurrentProject(proj)}
                          className="px-3 py-1.5 rounded-md bg-[#1c221e] hover:bg-[#252d28] text-[#f5f7f5] border border-[#303a33] text-xs cursor-pointer"
                        >
                          Select
                        </button>
                      )}
                      <button
                        onClick={() => handleRegenerateKey(proj.id)}
                        disabled={isRegeneratingKey}
                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-md bg-[#1c221e] hover:bg-[#252d28] text-[#e5ad55] border border-[#e5ad55]/30 text-xs cursor-pointer"
                        title="Generate a new ingestion API key"
                      >
                        <RefreshCw className={`h-3 w-3 ${isRegeneratingKey ? 'animate-spin' : ''}`} />
                        <span>Regenerate Key</span>
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
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
                className="flex items-center gap-1 px-2.5 py-1 rounded bg-[#1c221e] hover:bg-[#252d28] text-[#f5f7f5] border border-[#303a33] transition-colors cursor-pointer"
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
