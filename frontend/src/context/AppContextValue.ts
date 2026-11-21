import { createContext } from 'react';
import type {
  NavigationTab,
  Environment,
  DateRange,
  Project,
  BackendConnectionState
} from '../types';

export interface AppContextType {
  activeTab: NavigationTab;
  setActiveTab: (tab: NavigationTab) => void;
  currentProject: Project;
  setCurrentProject: (project: Project) => void;
  projects: Project[];
  environment: Environment;
  setEnvironment: (env: Environment) => void;
  dateRange: DateRange;
  setDateRange: (range: DateRange) => void;
  connectionState: BackendConnectionState;
  refreshHealth: () => Promise<void>;
  refreshProjects: () => Promise<void>;
  isMobileNavOpen: boolean;
  setIsMobileNavOpen: (open: boolean) => void;
}

export const AppContext = createContext<AppContextType | undefined>(undefined);
