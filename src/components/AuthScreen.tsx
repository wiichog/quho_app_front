import { LinearGradient } from 'expo-linear-gradient';
import { useVideoPlayer, VideoView } from 'expo-video';
import { ReactNode } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors, gradients, radius, spacing } from '@/theme';

/**
 * Loop local del video de la landing (quho.app), empaquetado en el bundle.
 * Se sirve desde assets — NO se hace streaming remoto: el login no debe depender
 * de la red para renderizar (un asset remoto pesado congelaba la pantalla de
 * inicio de sesión en algunos dispositivos / redes).
 */
const VIDEO_SOURCE = require('../../assets/video/auth-bg.mp4');

/**
 * Scaffold editorial para pantallas de autenticación: gradiente de marca (fondo
 * inmediato) + video local de fondo + velo oscuro + panel translúcido. Mantiene
 * el look de la landing (alto contraste, acento morado). El gradiente garantiza
 * un fondo branded al instante aunque el video aún no haya arrancado, por lo que
 * el login siempre es usable. Reutilizable por login, registro, recuperar, etc.
 */
export function AuthScreen({ children }: { children: ReactNode }) {
  const player = useVideoPlayer(VIDEO_SOURCE, (p) => {
    p.loop = true;
    p.muted = true;
    p.play();
  });

  return (
    <View style={styles.root}>
      <LinearGradient
        colors={gradients.hero as unknown as [string, string]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={StyleSheet.absoluteFill}
        pointerEvents="none"
      />
      <VideoView
        player={player}
        style={StyleSheet.absoluteFill}
        contentFit="cover"
        nativeControls={false}
        pointerEvents="none"
      />
      <View style={[StyleSheet.absoluteFill, styles.scrim]} pointerEvents="none" />

      <SafeAreaView style={styles.safe}>
        <KeyboardAvoidingView
          style={styles.flex}
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
          <ScrollView
            contentContainerStyle={styles.content}
            keyboardShouldPersistTaps="handled"
            showsVerticalScrollIndicator={false}
          >
            <View style={styles.panel}>{children}</View>
          </ScrollView>
        </KeyboardAvoidingView>
      </SafeAreaView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.black },
  scrim: { backgroundColor: 'rgba(0,0,0,0.55)' },
  safe: { flex: 1 },
  flex: { flex: 1 },
  content: { flexGrow: 1, justifyContent: 'center', padding: spacing.lg },
  panel: {
    backgroundColor: 'rgba(0,0,0,0.7)',
    borderColor: 'rgba(255,255,255,0.1)',
    borderWidth: 1,
    borderRadius: radius.lg,
    padding: spacing.lg,
  },
});
