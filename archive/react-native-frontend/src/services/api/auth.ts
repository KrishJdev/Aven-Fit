import { apiClient } from './client';
import { useAuthStore } from '@/store/authStore';

export const authApi = {
  requestOtp: async (phoneNumber: string) => {
    // MOCK FOR DEMO
    return new Promise((resolve) => setTimeout(() => resolve(undefined), 800));
  },

  verifyOtp: async (phoneNumber: string, code: string) => {
    // MOCK FOR DEMO
    return new Promise((resolve) => {
      setTimeout(async () => {
        const store = useAuthStore.getState();
        await store.setTokens('mock_access_token', 'mock_refresh_token');
        store.setUser({
          id: 'user_123',
          phoneNumber: phoneNumber,
          displayName: 'Krish',
          unitPreference: 'METRIC'
        });
        resolve({ accessToken: 'mock_access_token' });
      }, 800);
    });
  },

  fetchProfile: async () => {
    const user = await apiClient<any>('/users/me');
    useAuthStore.getState().setUser(user);
    return user;
  }
};

