import { useState, useEffect, useCallback, useRef } from 'react';
import type { ReactNode } from 'react';
import type {
  NavigationTab,
  Environment,
  DateRange,
  Project,
  BackendConnectionState
} from '../types';
import { fetchBackendHealth, fetchProjects, createProject } from '../services/api';
import { AppContext } from './AppContextValue';

const DEFAULT_PROJECTS: Project[] = [
  {
    id: 'proj_default',
    name: 'Autonomous Agent Service',
    slug: 'autonomous-agent-service',
    createdAt: '2026-11-19T00:00:00Z',
  },
  {
    id: 'proj_customer_support',
    name: 'Support Triage Agent',
    slug: 'support-triage-agent',
    createdAt: '2026-11-19T00:00:00Z',
  },
];

export function AppProvider({ children }: { children: ReactNode }) {
  const [activeTab, setActiveTab] = useState<NavigationTab>('overview');
  const [projects, setProjects] = useState<Project[]>(DEFAULT_PROJECTS);
  const [currentProject, setCurrentProject] = useState<Project>(DEFAULT_PROJECTS[0]);
  const [environment, setEnvironment] = useState<Environment>('development');
  const [dateRange, setDateRange] = useState<DateRange>('24h');
  const [isMobileNavOpen, setIsMobileNavOpen] = useState(false);

  const [connectionState, setConnectionState] = useState<BackendConnectionState>({
    isConnected: true,
    isLoading: false,
    lastChecked: null,
    latencyMs: 15,
    data: { status: 'healthy', service: 'AgentLens Backend', version: '0.1.0' },
    errorMessage: null,
  });

  const isCreatingProjectRef = useRef(false);

  const refreshProjects = useCallback(async () => {
    try {
      const liveProjects = await fetchProjects();
      if (liveProjects.length > 0) {
        setProjects(liveProjects);
        setCurrentProject((prev) => {
          const match = liveProjects.find((p) => p.id === prev.id);
          if (match) return match;
          const preferred =
            liveProjects.find((p) => p.name === 'Autonomous Agent Service') ||
            liveProjects.find((p) => !p.name.startsWith('Project test_'));
          return preferred || liveProjects[0];
        });
      } else if (!isCreatingProjectRef.current) {
        // No projects in DB yet: auto-provision default workspace project
        isCreatingProjectRef.current = true;
        try {
          const created = await createProject({
            name: 'Autonomous Agent Service',
            slug: 'autonomous-agent-service',
          });
          setProjects([created]);
          setCurrentProject(created);
        } catch {
          // If creation fails (e.g. backend read-only), keep defaults
        } finally {
          isCreatingProjectRef.current = false;
        }
      }
    } catch {
      // Backend not yet reachable or DB down; keep current state
    }
  }, []);

  const refreshHealth = useCallback(async () => {
    setConnectionState((prev) => ({ ...prev, isLoading: true }));
    const result = await fetchBackendHealth();
    setConnectionState(result);
    if (result.isConnected) {
      await refreshProjects();
    }
  }, [refreshProjects]);

  useEffect(() => {
    let isMounted = true;

    async function syncState() {
      const health = await fetchBackendHealth();
      if (!isMounted) return;
      setConnectionState(health);
      if (health.isConnected) {
        await refreshProjects();
      }
    }

    const initialTimer = setTimeout(() => {
      syncState();
    }, 500);

    const interval = setInterval(() => {
      syncState();
    }, 15000);

    return () => {
      isMounted = false;
      clearTimeout(initialTimer);
      clearInterval(interval);
    };
  }, [refreshProjects]);

  return (
    <AppContext.Provider
      value={{
        activeTab,
        setActiveTab,
        currentProject,
        setCurrentProject,
        projects,
        environment,
        setEnvironment,
        dateRange,
        setDateRange,
        connectionState,
        refreshHealth,
        refreshProjects,
        isMobileNavOpen,
        setIsMobileNavOpen,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}
