import React, { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AuthStackParamList } from '@/navigation/types';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';
import { authApi } from '@/services/api/auth';
import { theme } from '@/theme';

type Props = NativeStackScreenProps<AuthStackParamList, 'OtpVerification'>;

export const OtpVerificationScreen: React.FC<Props> = ({ route }) => {
  const { phoneNumber } = route.params;
  const [code, setCode] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleVerify = async () => {
    if (!code || code.length < 6) {
      setError('Please enter the 6-digit code');
      return;
    }
    
    setIsLoading(true);
    setError('');
    try {
      await authApi.verifyOtp(phoneNumber, code);
      // The authStore will update and RootNavigator will automatically switch to MainTab
    } catch (err: any) {
      setError(err.message || 'Invalid verification code');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Screen safeArea>
      <KeyboardAvoidingView 
        style={styles.container} 
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <View style={styles.header}>
          <Typography variant="h2" style={styles.title}>Enter Code</Typography>
          <Typography variant="body" color={theme.colors.textMuted}>
            We sent a verification code to {phoneNumber}
          </Typography>
        </View>

        <View style={styles.form}>
          <Input
            label="Verification Code"
            placeholder="123456"
            keyboardType="number-pad"
            maxLength={6}
            value={code}
            onChangeText={(text) => {
              setCode(text);
              setError('');
            }}
            error={error}
            autoFocus
            style={styles.otpInput} // Use our tabular typography internally
          />
        </View>

        <View style={styles.footer}>
          <Button 
            title="Verify & Continue" 
            onPress={handleVerify} 
            isLoading={isLoading} 
          />
        </View>
      </KeyboardAvoidingView>
    </Screen>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: theme.spacing.screenHorizontal,
  },
  header: {
    marginTop: theme.spacing.xl,
    marginBottom: theme.spacing.xl,
  },
  title: {
    marginBottom: theme.spacing.sm,
  },
  form: {
    flex: 1,
  },
  footer: {
    marginBottom: theme.spacing.lg,
  },
  otpInput: {
    fontSize: theme.typography.sizes.xl,
    letterSpacing: 4,
    fontVariant: ['tabular-nums'],
  }
});
