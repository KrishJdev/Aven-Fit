import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface UserProfile {
  id: string;
  phoneNumber: string;
  displayName: string | null;
  unitPreference: 'METRIC' | 'IMPERIAL';
}

interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  user: UserProfile | null;
  isLoading: boolean;
  
  // Actions
  setTokens: (accessToken: string, refreshToken: string) => Promise<void>;
  setUser: (user: UserProfile) => void;
  logout: () => Promise<void>;
  hydrate: () => Promise<void>; // Load from storage on boot
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  refreshToken: null,
  user: null,
  isLoading: true,

  setTokens: async (accessToken, refreshToken) => {
    await AsyncStorage.setItem('@AvenFit_access', accessToken);
    await AsyncStorage.setItem('@AvenFit_refresh', refreshToken);
    set({ accessToken, refreshToken });
  },

  setUser: (user) => {
    set({ user });
  },

  logout: async () => {
    await AsyncStorage.removeItem('@AvenFit_access');
    await AsyncStorage.removeItem('@AvenFit_refresh');
    set({ accessToken: null, refreshToken: null, user: null });
  },

  hydrate: async () => {
    try {
      const access = await AsyncStorage.getItem('@AvenFit_access');
      const refresh = await AsyncStorage.getItem('@AvenFit_refresh');
      
      set({
        accessToken: access || null,
        refreshToken: refresh || null,
        isLoading: false,
      });
    } catch (e) {
      set({ isLoading: false });
    }
  },
}));
