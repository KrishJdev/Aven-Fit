import { NavigatorScreenParams } from '@react-navigation/native';

export type AuthStackParamList = {
  Login: undefined;
  OtpVerification: { phoneNumber: string };
};

export type MainTabParamList = {
  Today: undefined;
  Train: undefined;
  Nutrition: undefined;
  Progress: undefined;
  Profile: undefined;
};

export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
};
