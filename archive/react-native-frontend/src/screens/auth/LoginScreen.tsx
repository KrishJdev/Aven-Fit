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

type Props = NativeStackScreenProps<AuthStackParamList, 'Login'>;

export const LoginScreen: React.FC<Props> = ({ navigation }) => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleContinue = async () => {
    if (!phoneNumber || phoneNumber.length < 10) {
      setError('Please enter a valid phone number');
      return;
    }
    
    setIsLoading(true);
    setError('');
    try {
      await authApi.requestOtp(phoneNumber);
      navigation.navigate('OtpVerification', { phoneNumber });
    } catch (err: any) {
      setError(err.message || 'Failed to request OTP');
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
          <Typography variant="h1" style={styles.title}>AVEN FIT</Typography>
          <Typography variant="body" color={theme.colors.textMuted}>
            Enter your phone number to sign in or create an account.
          </Typography>
        </View>

        <View style={styles.form}>
          <Input
            label="Phone Number"
            placeholder="+91 98765 43210"
            keyboardType="phone-pad"
            value={phoneNumber}
            onChangeText={(text) => {
              setPhoneNumber(text);
              setError('');
            }}
            error={error}
            autoFocus
          />
        </View>

        <View style={styles.footer}>
          <Button 
            title="Continue" 
            onPress={handleContinue} 
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
    marginTop: theme.spacing.xxl,
    marginBottom: theme.spacing.xl,
  },
  title: {
    letterSpacing: 1,
    marginBottom: theme.spacing.sm,
  },
  form: {
    flex: 1,
  },
  footer: {
    marginBottom: theme.spacing.lg,
  },
});
