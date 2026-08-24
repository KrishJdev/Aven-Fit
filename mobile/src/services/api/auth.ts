import { apiClient } from './client';
import { useAuthStore } from '@/store/authStore';

export const authApi = {
  requestOtp: (phoneNumber: string) => 
    apiClient('/auth/request-otp', {
      method: 'POST',
      body: JSON.stringify({ phoneNumber }),
    }),

  verifyOtp: async (phoneNumber: string, code: string) => {
    const response = await apiClient<{
      accessToken: string;
      refreshToken: string;
      user: any;
    }>('/auth/verify-otp', {
      method: 'POST',
      body: JSON.stringify({ phoneNumber, code }),
    });

    const store = useAuthStore.getState();
    await store.setTokens(response.accessToken, response.refreshToken);
    store.setUser(response.user);
    
    return response;
  },

  fetchProfile: async () => {
    const user = await apiClient<any>('/users/me');
    useAuthStore.getState().setUser(user);
    return user;
  }
};
