import { MaterialIcons } from '@expo/vector-icons';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
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
import { getChatHistory, sendChat } from '@/api/ai';
import { Text } from '@/components';
import { colors, radius, spacing, text } from '@/theme';

interface Msg {
  id: string;
  role: 'user' | 'assistant';
  content: string;
}

const SUGGESTIONS = [
  '¿Cómo puedo ahorrar más este mes?',
  '¿En qué estoy gastando de más?',
  'Dame un consejo financiero',
];

export default function AIChatScreen() {
  const router = useRouter();
  const [messages, setMessages] = useState<Msg[]>([]);
  const [input, setInput] = useState('');
  const listRef = useRef<FlatList<Msg>>(null);

  const history = useQuery({ queryKey: ['ai', 'history'], queryFn: getChatHistory });
  const send = useMutation({ mutationFn: sendChat });

  useEffect(() => {
    if (history.data) {
      setMessages(
        history.data.map((m) => ({
          id: String(m.id),
          role: m.role === 'assistant' ? 'assistant' : 'user',
          content: m.content,
        })),
      );
    }
  }, [history.data]);

  const append = (msg: Msg) => {
    setMessages((prev) => [...prev, msg]);
    setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 50);
  };

  const submit = (textValue: string) => {
    const content = textValue.trim();
    if (!content) return;
    append({ id: `u-${Date.now()}`, role: 'user', content });
    setInput('');
    send.mutate(content, {
      onSuccess: (res) => append({ id: `a-${Date.now()}`, role: 'assistant', content: res.response }),
      onError: () =>
        append({ id: `e-${Date.now()}`, role: 'assistant', content: 'No pude responder ahora. Intenta de nuevo.' }),
    });
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <View style={styles.headerTitle}>
          <View style={styles.aiDot}>
            <MaterialIcons name="auto-awesome" size={16} color={colors.white} />
          </View>
          <Text variant="h4">Asesor IA</Text>
        </View>
        <View style={{ width: 24 }} />
      </View>

      <KeyboardAvoidingView style={styles.flex} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        {messages.length === 0 && !history.isLoading ? (
          <View style={styles.empty}>
            <View style={styles.bigIcon}>
              <MaterialIcons name="auto-awesome" size={36} color={colors.teal} />
            </View>
            <Text variant="h4" center>
              Tu asesor financiero
            </Text>
            <Text variant="bodyMedium" color={colors.gray500} center style={{ marginBottom: spacing.lg }}>
              Pregúntame sobre tus finanzas
            </Text>
            {SUGGESTIONS.map((sug) => (
              <Pressable key={sug} style={styles.suggestion} onPress={() => submit(sug)}>
                <Text variant="bodyMedium" color={colors.gray700}>
                  {sug}
                </Text>
              </Pressable>
            ))}
          </View>
        ) : (
          <FlatList
            ref={listRef}
            data={messages}
            keyExtractor={(m) => m.id}
            contentContainerStyle={styles.chat}
            renderItem={({ item }) => (
              <View style={[styles.bubble, item.role === 'user' ? styles.user : styles.assistant]}>
                <Text variant="bodyMedium" color={item.role === 'user' ? colors.white : colors.gray800}>
                  {item.content}
                </Text>
              </View>
            )}
            ListFooterComponent={
              send.isPending ? (
                <View style={[styles.bubble, styles.assistant]}>
                  <ActivityIndicator color={colors.teal} />
                </View>
              ) : null
            }
          />
        )}

        <View style={styles.inputRow}>
          <TextInput
            value={input}
            onChangeText={setInput}
            placeholder="Escribe tu pregunta…"
            placeholderTextColor={colors.gray400}
            style={[styles.input, text.bodyMedium(colors.gray900)]}
            multiline
          />
          <Pressable onPress={() => submit(input)} style={styles.sendBtn} disabled={!input.trim()}>
            <MaterialIcons name="send" size={20} color={colors.white} />
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
  },
  headerTitle: { flexDirection: 'row', alignItems: 'center', gap: spacing.xs },
  aiDot: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.teal,
    alignItems: 'center',
    justifyContent: 'center',
  },
  empty: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.lg, gap: spacing.xs },
  bigIcon: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: colors.tealPale,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.md,
  },
  suggestion: {
    backgroundColor: colors.white,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.gray200,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    marginBottom: spacing.xs,
    alignSelf: 'stretch',
  },
  chat: { padding: spacing.lg, gap: spacing.sm },
  bubble: { maxWidth: '85%', borderRadius: radius.lg, padding: spacing.md },
  user: { backgroundColor: colors.teal, alignSelf: 'flex-end', borderBottomRightRadius: 4 },
  assistant: {
    backgroundColor: colors.white,
    alignSelf: 'flex-start',
    borderBottomLeftRadius: 4,
    borderWidth: 1,
    borderColor: colors.gray100,
  },
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
