import { MaterialIcons } from '@expo/vector-icons';
import { Tabs } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { LockScreen } from '@/components';
import { useAuthStore } from '@/store/authStore';
import { colors, fonts } from '@/theme';

export default function AppTabsLayout() {
  const locked = useAuthStore((s) => s.locked);
  const insets = useSafeAreaInsets();
  if (locked) return <LockScreen />;

  // Respetar el safe-area inferior (home indicator / "barra de Siri"): sin esto,
  // una altura fija empuja los íconos contra la barra. En equipos sin indicador
  // (insets.bottom = 0) caemos a un padding cómodo. Patrón tipo Instagram.
  const bottomInset = insets.bottom;

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.purple,
        tabBarInactiveTintColor: colors.gray400,
        tabBarStyle: {
          backgroundColor: colors.white,
          borderTopColor: colors.gray100,
          height: 60 + bottomInset,
          paddingBottom: bottomInset > 0 ? bottomInset : 10,
          paddingTop: 10,
        },
        tabBarItemStyle: { paddingTop: 2 },
        tabBarLabelStyle: {
          fontFamily: fonts.interSemiBold,
          fontSize: 10,
          letterSpacing: 0.8,
          textTransform: 'uppercase',
        },
      }}
    >
      <Tabs.Screen
        name="dashboard"
        options={{
          title: 'Inicio',
          tabBarIcon: ({ color, size }) => <MaterialIcons name="home" color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="transactions"
        options={{
          title: 'Movimientos',
          tabBarIcon: ({ color, size }) => (
            <MaterialIcons name="swap-vert" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="finances"
        options={{
          title: 'Finanzas',
          tabBarIcon: ({ color, size }) => (
            <MaterialIcons name="account-balance-wallet" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="gamification"
        options={{
          title: 'Logros',
          tabBarIcon: ({ color, size }) => (
            <MaterialIcons name="emoji-events" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Perfil',
          tabBarIcon: ({ color, size }) => (
            <MaterialIcons name="person" color={color} size={size} />
          ),
        }}
      />
      {/* Rutas accesibles pero sin pestaña propia */}
      <Tabs.Screen name="ai-chat" options={{ href: null }} />
      <Tabs.Screen name="subscription" options={{ href: null }} />
      <Tabs.Screen name="notifications" options={{ href: null }} />
      <Tabs.Screen name="change-password" options={{ href: null }} />
      <Tabs.Screen name="delete-account" options={{ href: null }} />
      <Tabs.Screen name="insights" options={{ href: null }} />
      <Tabs.Screen name="savings" options={{ href: null }} />
    </Tabs>
  );
}
