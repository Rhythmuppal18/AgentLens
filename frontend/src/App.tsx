import { Suspense, lazy } from 'react';
import { AppProvider } from './context/AppContext';
import { useApp } from './context/useApp';
import { Sidebar } from './components/layout/Sidebar';
import { Header } from './components/layout/Header';
import { OverviewView } from './components/overview/OverviewView';

const TraceExplorerView = lazy(() => import('./components/traces/TraceExplorerView').then((m) => ({ default: m.TraceExplorerView })));
const FailureDetectionView = lazy(() => import('./components/failures/FailureDetectionView').then((m) => ({ default: m.FailureDetectionView })));
const AnalyticsView = lazy(() => import('./components/analytics/AnalyticsView').then((m) => ({ default: m.AnalyticsView })));
const MLPlaygroundView = lazy(() => import('./components/ml/MLPlaygroundView').then((m) => ({ default: m.MLPlaygroundView })));
const SettingsView = lazy(() => import('./components/settings/SettingsView').then((m) => ({ default: m.SettingsView })));

function AppContent() {
  const { activeTab } = useApp();

  return (
    <div className="min-h-screen bg-[#090b0a] text-[#f5f7f5] flex font-sans antialiased selection:bg-[#b8f56a]/20 selection:text-[#b8f56a]">
      {/* Sidebar Navigation */}
      <Sidebar />

      {/* Main Container */}
      <div className="flex-1 flex flex-col min-w-0 lg:pl-64">
        {/* Global Application Header */}
        <Header />

        {/* View Router with Subtle Hardware-Accelerated Transitions */}
        <main className="flex-1 p-3.5 sm:p-5 lg:p-6 max-w-7xl w-full mx-auto">
          <div key={activeTab} className="view-transition">
            <Suspense fallback={<div className="h-64" />}>
              {activeTab === 'overview' && <OverviewView />}
              {activeTab === 'traces' && <TraceExplorerView />}
              {activeTab === 'failures' && <FailureDetectionView />}
              {activeTab === 'analytics' && <AnalyticsView />}
              {activeTab === 'ml-playground' && <MLPlaygroundView />}
              {activeTab === 'settings' && <SettingsView />}
            </Suspense>
          </div>
        </main>
      </div>
    </div>
  );
}

export function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}

export default App;
