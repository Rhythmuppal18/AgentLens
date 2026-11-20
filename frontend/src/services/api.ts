import type { BackendHealthResponse, BackendConnectionState } from '../types';

const PRIMARY_API_URL = 'http://localhost:8000/health';
const FALLBACK_API_URL = '/health';

export async function fetchBackendHealth(): Promise<BackendConnectionState> {
  const startTime = performance.now();

  // First attempt direct communication with FastAPI backend
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3500);

    const response = await fetch(PRIMARY_API_URL, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      },
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
    // If direct fails (e.g. CORS block before reload, or proxy environment), try fallback proxy
    try {
      const fallbackStart = performance.now();
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000);

      const response = await fetch(FALLBACK_API_URL, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
        },
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
      // Both failed - backend is down
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
