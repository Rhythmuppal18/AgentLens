import { useContext } from 'react';
import { AppContext } from './AppContextValue';
import type { AppContextType } from './AppContextValue';

export function useApp(): AppContextType {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}
