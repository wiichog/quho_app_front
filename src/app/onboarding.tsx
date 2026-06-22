import { MaterialIcons } from '@expo/vector-icons';
import { useMutation } from '@tanstack/react-query';
import { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  completeOnboarding,
  sendOnboardingMessage,
  startOnboarding,
} from '@/api/onboarding';
import { Button, OwlMark, Text } from '@/components';
import { useAuthStore } from '@/store/authStore';
import { colors, radius, spacing, text } from '@/theme';

interface ChatMsg {
  id: string;
  role: 'user' | 'assistant';
  content: string;
}

export default function OnboardingScreen() {
  const setOnboardingCompleted = useAuthStore((s) => s.setOnboardingCompleted);
  const [messages, setMessages] = useState<ChatMsg[]>([]);
  const [input, setInput] = useState('');
  const [startError, setStartError] = useState<string | null>(null);
  const listRef = useRef<FlatList<ChatMsg>>(null);

  const start = useMutation({ mutationFn: startOnboarding });
  const send = useMutation({ mutationFn: sendOnboardingMessage });
  const finish = useMutation({ mutationFn: completeOnboarding });

  useEffect(() => {
    start.mutate(undefined, {
      onSuccess: (res) =>
        setMessages([{ id: 'welcome', role: 'assistant', content: res.message }]),
      onError: () =>
        setStartError(
          'No pudimos iniciar el asistente ahora mismo. Puedes continuar y configurar tu presupuesto más tarde.',
        ),
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const append = (msg: ChatMsg) => {
    setMessages((prev) => [...prev, msg]);
    setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 50);
  };

  const onSend = () => {
    const content = input.trim();
    if (!content) return;
    append({ id: `u-${Date.now()}`, role: 'user', content });
    setInput('');
    send.mutate(content, {
      onSuccess: (res) => {
        const reply = res.response || res.message || '…';
        append({ id: `a-${Date.now()}`, role: 'assistant', content: reply });
      },
      onError: () =>
        append({
          id: `e-${Date.now()}`,
          role: 'assistant',
          content: 'Tuve un problema procesando tu mensaje. Intenta de nuevo.',
        }),
    });
  };

  const onFinish = () => {
    finish.mutate(undefined, {
      onSuccess: () => setOnboardingCompleted(true),
      onError: () => setOnboardingCompleted(true), // no bloquear al usuario
    });
  };

  const hasConversation = messages.some((m) => m.role === 'user');

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <OwlMark size={38} />
        <View style={styles.flex}>
          <Text variant="h3">Configura tu presupuesto</Text>
          <Text variant="bodySmall" color={colors.gray500}>
            Cuéntale a tu asesor sobre tus ingresos y gastos
          </Text>
        </View>
        <Pressable onPress={() => setOnboardingCompleted(true)} hitSlop={8}>
          <Text variant="caption" color={colors.gray400}>
            Omitir
          </Text>
        </Pressable>
      </View>

      {start.isPending ? (
        <View style={styles.center}>
          <ActivityIndicator color={colors.teal} />
          <Text variant="bodyMedium" color={colors.gray500} style={{ marginTop: spacing.sm }}>
            Iniciando tu asesor…
          </Text>
        </View>
      ) : startError ? (
        <View style={styles.center}>
          <MaterialIcons name="cloud-off" size={40} color={colors.gray300} />
          <Text variant="bodyMedium" color={colors.gray500} center style={{ marginTop: spacing.sm }}>
            {startError}
          </Text>
          <Button
            title="Continuar"
            onPress={() => setOnboardingCompleted(true)}
            fullWidth={false}
            style={{ marginTop: spacing.lg }}
          />
        </View>
      ) : (
        <KeyboardAvoidingView
          style={styles.flex}
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          keyboardVerticalOffset={8}
        >
          <FlatList
            ref={listRef}
            data={messages}
            keyExtractor={(m) => m.id}
            contentContainerStyle={styles.chat}
            renderItem={({ item }) => <Bubble msg={item} />}
            ListFooterComponent={
              send.isPending ? (
                <View style={[styles.bubble, styles.assistant]}>
                  <ActivityIndicator color={colors.teal} />
                </View>
              ) : null
            }
          />

          {hasConversation ? (
            <View style={styles.finishWrap}>
              <Button
                title="Crear mi presupuesto"
                onPress={onFinish}
                loading={finish.isPending}
                icon="auto-awesome"
              />
            </View>
          ) : null}

          <View style={styles.inputRow}>
            <TextInput
              value={input}
              onChangeText={setInput}
              placeholder="Escribe aquí…"
              placeholderTextColor={colors.gray400}
              style={[styles.input, text.bodyMedium(colors.gray900)]}
              multiline
            />
            <Pressable onPress={onSend} style={styles.sendBtn} disabled={!input.trim()}>
              <MaterialIcons name="send" size={20} color={colors.white} />
            </Pressable>
          </View>
        </KeyboardAvoidingView>
      )}
    </SafeAreaView>
  );
}

function Bubble({ msg }: { msg: ChatMsg }) {
  const isUser = msg.role === 'user';
  return (
    <View style={[styles.bubble, isUser ? styles.user : styles.assistant]}>
      <Text variant="bodyMedium" color={isUser ? colors.white : colors.gray800}>
        {msg.content}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.lg,
    gap: spacing.sm,
  },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.xl },
  chat: { padding: spacing.lg, gap: spacing.sm },
  bubble: { maxWidth: '85%', borderRadius: radius.lg, padding: spacing.md },
  user: { backgroundColor: colors.teal, alignSelf: 'flex-end', borderBottomRightRadius: 4 },
  assistant: { backgroundColor: colors.white, alignSelf: 'flex-start', borderBottomLeftRadius: 4, borderWidth: 1, borderColor: colors.gray100 },
  finishWrap: { paddingHorizontal: spacing.lg, paddingBottom: spacing.sm },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: spacing.xs,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.gray100,
    backgroundColor: colors.white,
  },
  input: {
    flex: 1,
    maxHeight: 120,
    minHeight: 44,
    backgroundColor: colors.gray50,
    borderRadius: radius.lg,
    paddingHorizontal: spacing.md,
    paddingTop: spacing.sm,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: colors.teal,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
