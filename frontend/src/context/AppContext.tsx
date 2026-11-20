import { useState, useEffect, useCallback } from 'react';
import type { ReactNode } from 'react';
import type {
  NavigationTab,
  Environment,
  DateRange,
  Project,
  BackendConnectionState
} from '../types';
import { fetchBackendHealth } from '../services/api';
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
  const [projects] = useState<Project[]>(DEFAULT_PROJECTS);
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

  const refreshHealth = useCallback(async () => {
    setConnectionState((prev) => ({ ...prev, isLoading: true }));
    const result = await fetchBackendHealth();
    setConnectionState(result);
  }, []);

  useEffect(() => {
    let isMounted = true;

    async function syncHealth() {
      const result = await fetchBackendHealth();
      if (isMounted) {
        setConnectionState(result);
      }
    }

    const initialTimer = setTimeout(() => {
      syncHealth();
    }, 1500);

    const interval = setInterval(() => {
      syncHealth();
    }, 15000);

    return () => {
      isMounted = false;
      clearTimeout(initialTimer);
      clearInterval(interval);
    };
  }, []);

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
        isMobileNavOpen,
        setIsMobileNavOpen,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}
