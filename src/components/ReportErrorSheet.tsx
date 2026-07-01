import { MaterialIcons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { useState } from 'react';
import { Alert, Modal, Pressable, StyleSheet, View } from 'react-native';
import { Button } from './Button';
import { Text } from './Text';
import { TextField } from './TextField';
import { reportTicket, type ReportAttachment } from '@/api/tickets';
import { collectDeviceContext } from '@/features/report/context';
import { enqueueReport } from '@/features/report/queue';
import { colors, radius, spacing } from '@/theme';

interface Props {
  visible: boolean;
  onClose: () => void;
  /** Ruta actual (expo-router) capturada al abrir. */
  screen?: string;
  /** Stack del último error capturado, si lo hubo. */
  stackTrace?: string;
}

export function ReportErrorSheet({ visible, onClose, screen, stackTrace }: Props) {
  const [description, setDescription] = useState('');
  const [attachment, setAttachment] = useState<ReportAttachment | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const reset = () => {
    setDescription('');
    setAttachment(null);
    setSubmitting(false);
  };

  const close = () => {
    reset();
    onClose();
  };

  const pickImage = async () => {
    try {
      const res = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        quality: 0.7,
      });
      if (!res.canceled && res.assets[0]) {
        const a = res.assets[0];
        setAttachment({
          uri: a.uri,
          name: a.fileName ?? `captura-${Date.now()}.jpg`,
          type: a.mimeType ?? 'image/jpeg',
        });
      }
    } catch {
      Alert.alert('No disponible', 'No se pudo abrir la galería.');
    }
  };

  const submit = async () => {
    if (description.trim().length < 3) {
      Alert.alert('Cuéntanos más', 'Describe brevemente el problema.');
      return;
    }
    setSubmitting(true);
    const payload = {
      description: description.trim(),
      type: 'bug' as const,
      ...collectDeviceContext(),
      screen: screen ?? '',
      stack_trace: stackTrace ?? '',
      attachment,
    };
    try {
      await reportTicket(payload);
      close();
      Alert.alert('¡Gracias!', 'Recibimos tu reporte y lo revisaremos pronto.');
    } catch (err) {
      // Sin red (o fallo de envío): encolar para reintentar.
      const status = (err as { status?: number })?.status;
      if (!status || status === 0) {
        await enqueueReport(payload);
        close();
        Alert.alert('Guardado', 'No hay conexión ahora. Tu reporte se enviará automáticamente.');
      } else {
        setSubmitting(false);
        Alert.alert('Ups', 'No pudimos enviar tu reporte. Inténtalo de nuevo.');
      }
    }
  };

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={close}>
      <Pressable style={styles.backdrop} onPress={close} />
      <View style={styles.sheet}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.sm }}>
          Reportar un problema
        </Text>
        <Text variant="bodySmall" color={colors.gray500} style={{ marginBottom: spacing.md }}>
          Describe qué pasó. Adjuntamos automáticamente la versión y el dispositivo.
        </Text>

        <TextField
          label="¿Qué ocurrió?"
          placeholder="Ej. La app se cerró al guardar un gasto…"
          value={description}
          onChangeText={setDescription}
          multiline
          numberOfLines={4}
          style={styles.textArea}
        />

        <Pressable style={styles.attachRow} onPress={pickImage}>
          <MaterialIcons
            name={attachment ? 'check-circle' : 'add-photo-alternate'}
            size={20}
            color={attachment ? colors.purple : colors.gray500}
          />
          <Text variant="bodyMedium" color={attachment ? colors.purple : colors.gray600}>
            {attachment ? 'Captura adjuntada' : 'Adjuntar captura (opcional)'}
          </Text>
          {attachment ? (
            <Pressable onPress={() => setAttachment(null)} hitSlop={8} style={{ marginLeft: 'auto' }}>
              <MaterialIcons name="close" size={18} color={colors.gray400} />
            </Pressable>
          ) : null}
        </Pressable>

        <Button
          title="Enviar reporte"
          icon="send"
          onPress={submit}
          loading={submitting}
          style={{ marginTop: spacing.md }}
        />
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  backdrop: { flex: 1, backgroundColor: '#00000055' },
  sheet: {
    backgroundColor: colors.white,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  handle: { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gray300, alignSelf: 'center' },
  textArea: { minHeight: 96, textAlignVertical: 'top' },
  attachRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    paddingVertical: spacing.sm,
  },
});
