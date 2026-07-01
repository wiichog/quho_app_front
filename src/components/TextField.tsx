import { MaterialIcons } from '@expo/vector-icons';
import { useState } from 'react';
import {
  Pressable,
  StyleSheet,
  TextInput,
  TextInputProps,
  View,
} from 'react-native';
import { colors, radius, spacing, text } from '@/theme';
import { Text } from './Text';

export interface TextFieldProps extends TextInputProps {
  label?: string;
  error?: string;
  leftIcon?: keyof typeof MaterialIcons.glyphMap;
  /** Activa el botón de mostrar/ocultar para contraseñas. */
  password?: boolean;
  /** 'dark' = campo sobre fondo oscuro (logins editoriales con acento morado). */
  tone?: 'light' | 'dark';
}

export function TextField({
  label,
  error,
  leftIcon,
  password = false,
  tone = 'light',
  style,
  ...rest
}: TextFieldProps) {
  const [focused, setFocused] = useState(false);
  const [hidden, setHidden] = useState(password);

  const dark = tone === 'dark';
  const accent = dark ? colors.purple : colors.purple;
  const idleBorder = dark ? 'rgba(255,255,255,0.15)' : colors.gray200;
  const borderColor = error ? colors.red : focused ? accent : idleBorder;
  const fieldBg = dark ? 'rgba(255,255,255,0.06)' : colors.white;
  const inputColor = dark ? colors.white : colors.gray900;
  const placeholderColor = dark ? 'rgba(255,255,255,0.3)' : colors.gray400;
  const iconColor = dark ? 'rgba(255,255,255,0.4)' : colors.gray400;

  return (
    <View style={styles.wrapper}>
      {label ? (
        <Text
          variant="caption"
          color={dark ? 'rgba(255,255,255,0.5)' : colors.gray600}
          style={[styles.label, dark ? styles.labelDark : null]}
        >
          {label}
        </Text>
      ) : null}
      <View style={[styles.field, { borderColor, backgroundColor: fieldBg }]}>
        {leftIcon ? (
          <MaterialIcons name={leftIcon} size={20} color={iconColor} style={styles.leftIcon} />
        ) : null}
        <TextInput
          style={[styles.input, text.bodyMedium(inputColor), style]}
          placeholderTextColor={placeholderColor}
          secureTextEntry={hidden}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          {...rest}
        />
        {password ? (
          <Pressable onPress={() => setHidden((h) => !h)} hitSlop={8}>
            <MaterialIcons
              name={hidden ? 'visibility-off' : 'visibility'}
              size={20}
              color={iconColor}
            />
          </Pressable>
        ) : null}
      </View>
      {error ? (
        <Text variant="caption" color={colors.red} style={styles.error}>
          {error}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: { marginBottom: spacing.md },
  label: { marginBottom: spacing.xxs },
  labelDark: { textTransform: 'uppercase', letterSpacing: 1 },
  field: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1.5,
    borderRadius: radius.xs,
    paddingHorizontal: spacing.md,
    height: 52,
  },
  leftIcon: { marginRight: spacing.xs },
  input: { flex: 1, height: '100%' },
  error: { marginTop: spacing.xxs },
});
