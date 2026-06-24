import {
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
} from '@expo-google-fonts/inter';
import {
  Poppins_400Regular,
  Poppins_500Medium,
  Poppins_600SemiBold,
  Poppins_700Bold,
  useFonts,
} from '@expo-google-fonts/poppins';
import { QueryClientProvider } from '@tanstack/react-query';
import { Stack, useRouter, useSegments } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { queryClient } from '@/api/queryClient';
import { onSessionExpired } from '@/api/tokenStorage';
import { ErrorBoundary } from '@/components';
import { ReportProvider } from '@/features/report/ReportProvider';
import { useAuthStore } from '@/store/authStore';

SplashScreen.preventAutoHideAsync().catch(() => undefined);

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    Poppins_400Regular,
    Poppins_500Medium,
    Poppins_600SemiBold,
    Poppins_700Bold,
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
  });

  const bootstrap = useAuthStore((s) => s.bootstrap);
  const handleSessionExpired = useAuthStore((s) => s.handleSessionExpired);
  const status = useAuthStore((s) => s.status);

  useEffect(() => {
    bootstrap();
    const off = onSessionExpired(handleSessionExpired);
    return off;
  }, [bootstrap, handleSessionExpired]);

  const ready = fontsLoaded && status !== 'loading';

  useEffect(() => {
    if (ready) SplashScreen.hideAsync().catch(() => undefined);
  }, [ready]);

  if (!ready) return null;

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <QueryClientProvider client={queryClient}>
          <StatusBar style="dark" />
          <ReportProvider>
            <ErrorBoundary>
              <RootNavigator />
            </ErrorBoundary>
          </ReportProvider>
        </QueryClientProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

/** Gating de rutas según estado de sesión y onboarding. */
function RootNavigator() {
  const router = useRouter();
  const segments = useSegments();
  const status = useAuthStore((s) => s.status);
  const onboardingCompleted = useAuthStore((s) => s.onboardingCompleted);

  useEffect(() => {
    const inAuthGroup = segments[0] === '(auth)';
    const inOnboarding = segments[0] === 'onboarding';

    if (status === 'unauthenticated' && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (status === 'authenticated') {
      if (!onboardingCompleted && !inOnboarding) {
        router.replace('/onboarding');
      } else if (onboardingCompleted && (inAuthGroup || inOnboarding)) {
        router.replace('/(app)/dashboard');
      }
    }
  }, [status, onboardingCompleted, segments, router]);

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="index" />
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="onboarding" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}
