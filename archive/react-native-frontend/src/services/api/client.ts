import { useAuthStore } from '@/store/authStore';
import { Platform } from 'react-native';

// For Android emulator, localhost is 10.0.2.2
export const API_BASE_URL = __DEV__
  ? Platform.OS === 'android'
    ? 'http://10.0.2.2:8080/api'
    : 'http://localhost:8080/api'
  : 'https://api.avenfit.com/api';

export class ApiError extends Error {
  constructor(public status: number, public data: any) {
    super(data?.message || 'An API error occurred');
  }
}

export const apiClient = async <T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> => {
  const store = useAuthStore.getState();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (store.accessToken) {
    headers['Authorization'] = `Bearer ${store.accessToken}`;
  }

  let response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  // Handle 401 Unauthorized (Token Expiry)
  if (response.status === 401 && store.refreshToken) {
    try {
      const refreshRes = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: store.refreshToken }),
      });
      
      if (!refreshRes.ok) throw new Error('Refresh failed');
      
      const refreshData = await refreshRes.json();
      await store.setTokens(refreshData.accessToken, refreshData.refreshToken);
      
      // Retry original request
      headers['Authorization'] = `Bearer ${refreshData.accessToken}`;
      response = await fetch(`${API_BASE_URL}${endpoint}`, {
        ...options,
        headers,
      });
    } catch (refreshErr) {
      await store.logout();
      throw new ApiError(401, { message: 'Session expired. Please log in again.' });
    }
  }

  const isJson = response.headers.get('content-type')?.includes('application/json');
  const data = isJson ? await response.json() : await response.text();

  if (!response.ok) {
    throw new ApiError(response.status, data);
  }

  return data as T;
};
